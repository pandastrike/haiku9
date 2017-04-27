{isMatch} = require "fairmont"

module.exports =

  pathWithUnderscore: (path) -> isMatch /(^|\/)_/, path

  isBowerComponentsPath: (path) -> isMatch /bower_components/, path

  isNodeModulesPath: (path) -> isMatch /node_modules/, path
