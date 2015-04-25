var fs, path, rr, walk;

fs = require('fs');

path = require('path');

walk = require('walk');

rr = {};

rr.fileHandler = function(root, fileStat, next) {
  return fs.readFile(path.resolve(root, fileStat.name), function(err, data) {
    if (err != null) {
      throw err;
    }
    console.log(root, fileStat.name, data.toString());
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
