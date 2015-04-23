{resolve} = require "path"
{async} = require "fairmont"
express = require "express"
app = express()
{compile, clean} = require "./compile"

log = (require "log4js").getLogger("h9")

logger = (request, response, next) ->
    {method, url} = request
    log.info "request", "#{method} #{url}"
    next()
    response.on "finish", ->
      code = response.statusCode
      log.info "respond", "#{method} #{url} #{code}"


server = async ({source, target, port}) ->

  source = resolve source
  target = resolve target

  # do an initial build and set up watchers
  yield clean {target}
  yield compile {source, target}

  express()
  .use logger
  .use express.static target, extensions: [ 'html' ]
  .listen port, -> log.info "Listening on port #{port}"

module.exports = server
