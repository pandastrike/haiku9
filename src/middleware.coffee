URL = require "url"
{dirname, basename, extname, join} = require "path"
{async} = require "fairmont"
mime = require "mime-types"
Asset = require "./asset"

classify = (accept) ->
  switch
    when accept.match /html/ then "html"
    when accept.match /css/ then "css"
    when accept.match /javascript/ then "javascript"
    else undefined


create = (root) ->

  async (request, response, next) ->

    # You can only GET things from this middleware
    if request.method == "GET"

      # Parse out the directory and filename
      path = URL.parse(request.url).pathname[1..]
      directory = join root, (dirname path)
      extension = extname path
      name = basename path, extension
      if name == "" then name = "index"

      format = classify request.headers.accept
      format ?= classify mime.lookup extension
      format ?= "text"

      # Find the corresponding asset from the local filesystem
      try
        asset = yield Asset.globNameForFormat directory, name, format
        try
          response.setHeader 'content-type',
            (mime.contentType format) || (mime.contentType extension)
          response.end (yield asset.render format), 200
        catch error
          response.end "Unknown server error: #{request.url}", 500
      catch error
        # We were unable to find a corresponding asset
        # response.end "Not found: #{request.url}", 404
        next()
    else
      next()

module.exports = {create}
