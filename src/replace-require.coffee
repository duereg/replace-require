fs = require 'fs'
path = require 'path'
walk = require 'walk'

rr = {}

rr.fileHandler = (root, fileStat, next) ->
  fs.readFile path.resolve(root, fileStat.name), (err, data) ->
    throw err if err?

    pattern = /let\s.*\srequire.*\n/
    fileContents = data.toString()
    matches = pattern.exec fileContents

    console.log root, fileStat.name, matches
    next()

rr.errorsHandler = (root, nodeStatsArray, next) ->
  nodeStatsArray.forEach (n) ->
    console.error "[ERROR] #{n.name}"
    console.error n.error.message || (n.error.code + ": " + n.error.path)

  next()

rr.endHandler = ->
  console.log 'all done'

rr.run = (directory) ->
  walker  = walk.walk(directory, { followLinks: false })

  walker.on("file", rr.fileHandler)
  walker.on("errors", rr.errorsHandler)
  walker.on("end", rr.endHandler)

module.exports = rr
