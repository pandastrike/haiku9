http = require "http"
{join} = require "path"

mime = require "mime-types"
{async, isReadStream,
spread,
events, go, map, tee} = require "fairmont"
{define, run, context} = require "panda-9000"
{find, render} = require "./asset"

httpLogger = ({request, response}) ->
  start = Date.now()
  {url, method} = request
  response.on "finish", ->
    duration = Date.now() - start
    code = response.statusCode
    console.log "#{method} #{url} - #{code} (#{duration}ms)"

define "serve", ["survey"], ->
  {source, server} = require "./configuration"
  watcher = require "chokidar"

  # re-run the survey when things change
  watcher.watch source, ignoreInitial: true
  .on "all", (event) -> run "survey"


  http = require "http"

  port = if server?.port? then server.port else 1337

  server = http
  .createServer()
  .listen port,
  -> console.log "Haiku9 HTTP server listening on port #{port}."

  go [
    events "request", server
    map spread (request, response) -> {request, response}
    tee httpLogger
    tee async ({request, response}) ->

      try
        {path, source} = context "/", request.url.split('?')[0]
        extension = if source.extension == ""
          ".html"
        else
          source.extension
        if ((asset = find {path, extension})? ||
            (asset = find {path: (join path, "index"), extension})?)
          yield render asset
          {target} = asset
          response.setHeader "content-type",  mime.lookup target.extension
          response.statusCode = 200
          # if isReadStream target.content
          if target.content.pipe?
            target.content.pipe response
          else
            response.end target.content
        else
          response.statusCode = 404
          response.setHeader "content-type", "text/plain"
          response.end "Not Found"

      catch error
        console.error error.stack
        response.statusCode = 503
        response.statusMessage = "Unknown server error"
        response.end "Unknown server error"
  ]
