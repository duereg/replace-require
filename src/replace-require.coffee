fs = require 'fs'
path = require 'path'
walk = require 'walk'

rr = {}

rr.fileHandler = (root, fileStat, next) ->
  fs.readFile path.resolve(root, fileStat.name), (err, data) ->
    throw err if err?

    # pattern = /^let|var\s(\D*)\s=?\srequire\('(\D*)'\)/g
    # https://github.com/systemjs/systemjs/blob/master/dist/system.src.js#1156
    pattern = /(?:^\uFEFF?|[^$_a-zA-Z\xA0-\uFFFF."'])require\s*\(\s*("[^"\\]*(?:\\.[^"\\]*)*"|'[^'\\]*(?:\\.[^'\\]*)*')\s*\)/g;
    fileContents = data.toString()

    lines = fileContents.split('\n');

    lines.forEach (line, index) ->
      i = 0
      matches = pattern.exec line

      while matches and  i < 3
        matches = pattern.exec line

        tempStr = line.replace(pattern, 'from $1')
        tempStr = tempStr.replace('=', '')
        tempStr = tempStr.replace('=from', 'from')
        tempStr = tempStr.replace('let', 'import')
        tempStr = tempStr.replace('const', 'import')
        console.log(tempStr)
        lines[index] = tempStr
        i++

    translatedFile = lines.join('\n')
    fs.writeFile(path.join(root, fileStat.name), translatedFile)
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
