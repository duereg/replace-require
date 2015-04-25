fs = require 'fs'
path = require 'path'
walk = require 'walk'

rr = {}

rr.fileHandler = (root, fileStat, next) ->
  fs.readFile path.resolve(root, fileStat.name), (buffer) ->
    console.log fileStat.name, buffer.byteLength
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

  walker.on("file", fileHandler)
  walker.on("errors", errorsHandler)
  walker.on("end", endHandler)

module.exports = rr
