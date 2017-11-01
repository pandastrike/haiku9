compile = require "./compile"

module.exports = (env) ->
  console.log "BEFORE CONFIG"
  config = require "../read"
  console.log "HAVE CONFIG!!!!"
  compile config, env
