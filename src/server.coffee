{resolve} = require "path"
{async} = require "fairmont"
Middleware = require "./middleware"
app = do require "express"
root = resolve "public"
logger = (require "log4js").getLogger()
log =
  request: (request, response, next) ->
    {method, url} = request
    logger.info "#{method} #{url}"
    next()
    response.on "finish", ->
      code = response.statusCode
      logger.info "#{method} #{url} #{code}"

app.use log.request
app.use Middleware.create root
# app.use log.response

module.exports = app
