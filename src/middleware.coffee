URL = require "url"
{dirname, basename, extname, join} = require "path"
{async, first, rest, collect, select, keys, to_json, blank} = require "fairmont"
mime = require "mime-types"
accepts = require "accepts"
Asset = require "./asset"

create = (root) ->

  supported_formats = keys Asset.formatsFor
  async (request, response, next) ->

    # You can only GET things from this middleware
    if request.method == "GET"

      # Parse out the directory and filename
      path = URL.parse(request.url).pathname[1..]
      directory = join root, (dirname path)
      extension = extname path
      name = basename path, extension
      if name == "" then name = "index"

      formats = if blank extension
        supported_formats
      else
        [(rest extension), supported_formats...]

      acceptable = do (accept = accepts request)->
        (format) -> accept.type [format]

      for format in (collect select acceptable, formats)
        assets = yield Asset.globNameForFormat directory, name, format
        if (asset = first assets)?
          response.setHeader 'content-type',
            (mime.contentType format) || (mime.contentType extension)
          if (content = (yield asset.render format)).pipe?
            content.pipe response
          else
            response.end content
          return
    next()

module.exports = {create}
