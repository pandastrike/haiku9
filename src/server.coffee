{resolve} = require "path"
{async} = require "fairmont"
Middleware = require "./middleware"
app = do require "express"
root = resolve "public"
log = (require "log4js").getLogger("h9")
logger = (request, response, next) ->
    {method, url} = request
    log.info "request", "#{method} #{url}"
    next()
    response.on "finish", ->
      code = response.statusCode
      log.info "respond", "#{method} #{url} #{code}"

app.use logger
app.use Middleware.create root
# app.use log.response

module.exports = app
