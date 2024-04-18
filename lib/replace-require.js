var fs, path, rr, walk;

fs = require('fs');

path = require('path');

walk = require('walk');

rr = {};

const pattern = /(?:^\uFEFF?|[^$_a-zA-Z\xA0-\uFFFF."'])require\s*\(\s*("[^"\\]*(?:\\.[^"\\]*)*"|'[^'\\]*(?:\\.[^'\\]*)*')\s*\)/g;

function requireHandler(lines, line, index) {
  var i, matches, results, tempStr;
  i = 0;
  matches = pattern.exec(line);
  results = [];
  while (matches && i < 3) {
    matches = pattern.exec(line);
    tempStr = line.replace(pattern, 'from $1');
    tempStr = tempStr.replace('=', '');
    tempStr = tempStr.replace('=from', 'from');
    tempStr = tempStr.replace('let', 'import');
    tempStr = tempStr.replace('const', 'import');
    console.log(tempStr);
    lines[index] = tempStr;
    results.push(i++);
  }
  return results;
}

function exportHandler(lines, line, index) {
  if (line.startsWith('module.exports =')) {
    const tempStr = line.replace('module.exports =', 'export default');
    console.log(tempStr);
    lines[index] = tempStr;
  }
}

function runHandlers(lines, line, index) {
  requireHandler(lines, line, index);
  exportHandler(lines, line, index);
}

rr.fileHandler = function(root, fileStat, next) {
  return fs.readFile(path.resolve(root, fileStat.name), function(err, data) {
    var fileContents, lines, pattern, translatedFile;
    if (err != null) {
      throw err;
    }
    fileContents = data.toString();
    lines = fileContents.split('\n');
    lines.forEach((line, index) => runHandlers(lines, line, index));
    translatedFile = lines.join('\n');
    fs.writeFile(path.join(root, fileStat.name), translatedFile, console.error);
    return next();
  });
};

rr.errorsHandler = function(root, nodeStatsArray, next) {
  nodeStatsArray.forEach(function(n) {
    console.error("[ERROR] " + n.name);
    return console.error(n.error.message || (n.error.code + ": " + n.error.path));
  });
  return next();
};

rr.endHandler = function() {
  return console.log('all done');
};

rr.run = function(directory) {
  var walker;
  walker = walk.walk(directory, {
    followLinks: false
  });
  walker.on("file", rr.fileHandler);
  walker.on("errors", rr.errorsHandler);
  return walker.on("end", rr.endHandler);
};

module.exports = rr;
