http = require "http"
URL = require "url"
{dirname, basename, extname, join} = require "path"

Asset = require "../src/asset"

http.createServer (request, response) ->

  # Is this a GET request?
  if request.method is "GET"
    # Parse out the directory and filename
    path = URL.parse(request.url).pathname[1..]
    directory = join __dirname, dirname path
    extension = extname path
    name = basename path, extension
    if name is "" then name = "index"

    # Determine which format to use
    format = if extension is ".css"
      "css"
    else if extension is ".js"
      "javascript"
    else if request.headers.accept.match /html/
      "html"

    # Find the corresponding asset from the local filesystem
    Asset.globNameForFormat directory, name, format
    .then (asset) ->
      # Render it to the desired format
      asset.render format
      .then (html) ->
        response.statusCode = 200
        response.end html

      # Render error!
      .catch (error) ->
        response.statusCode = 500
        response.write "Uknown server error: #{request.url}"
        response.end error.message

    # We were unable to find a corresponding asset
    .catch (err) ->
      response.statusCode = 404
      response.end "Not found: #{request.url}"

  else
    response.statusCode = 404
    response.end "Not found: #{request.url}"

.listen 1337
