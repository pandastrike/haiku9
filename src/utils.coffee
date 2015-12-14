{isMatch} = require "fairmont"

module.exports =

  pathWithUnderscore: (path) -> isMatch /(^|\/)_/, path
