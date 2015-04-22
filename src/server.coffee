{resolve} = require "path"
{call} = require "fairmont"
Middleware = require "./middleware"
express = require "express"
app = express()

source = resolve "public"
destination = resolve "build"

log = (require "log4js").getLogger("h9")

logger = (request, response, next) ->
    {method, url} = request
    log.info "request", "#{method} #{url}"
    next()
    response.on "finish", ->
      code = response.statusCode
      log.info "respond", "#{method} #{url} #{code}"

call ->
  app.use logger
  app.use (yield Middleware.create source, destination)
  app.use express.static destination, extensions: [ 'html' ]
  # app.use log.response

module.exports = app
