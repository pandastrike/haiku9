compile = require "./compile"

module.exports = (env) ->
  config = require "../read"
  compile config, env
