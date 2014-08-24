http = require "http"
URL = require "url"
{dirname, basename, extname, join} = require "path"

Asset = require "../src/asset"

http.createServer (request, response) ->

  # Is this a request for an HTML asset?
  if request.method is "GET" and request.headers.accept.match /html/

    # Parse out the directory and filename
    path = URL.parse(request.url).pathname[1..]
    directory = join __dirname, dirname path
    extension = extname path
    name = basename path, extension
    if name is "" then name = "index"

    # Find the corresponding asset from the local filesystem
    Asset.globNameForFormat directory, name, "html"
    .success (asset) ->

      # Render it to HTML
      asset.render "html"
      .success (html) ->
        response.end html, 200

      # Render error!
      .error (error) ->
        response.end "Unknown server error: #{request.url}", 500

    # We were unable to find a corresponding asset
    .error ->
      response.end "Not found: #{request.url}", 404

.listen 1337
