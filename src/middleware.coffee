# URL = require "url"
# {dirname, basename, extname, join} = require "path"
# {async, first, rest, collect, select, keys, to_json, blank} = require "fairmont"
# mime = require "mime-types"
# accepts = require "accepts"

{watch} = require "fs"
{join} = require "path"
{async, mkdirp, readdir, is_directory, rmdir, rm,
  stat, exists} = require "fairmont"
log = (require "log4js").getLogger("h9")
Asset = require "./asset"

clean = async (path, recursive = true) ->
  if yield exists path
    files = yield readdir path
    for file in files
      _path = join path, file
      if (yield is_directory _path)
        (yield clean _path) if recursive
      else
        yield rm _path
    (yield rmdir path) if recursive

hashes = {}
watched = {}
mapping = {}
compile = async (source, destination, recursive = true) ->
  log.info "Rebuilding #{source}..."
  yield mkdirp "0777", destination
  unless watched[source]?
    watched[source] = true
    watch source, async ->
      yield compile source, destination, false
  files = yield readdir source
  for file in files when file[0] != "_"
    path = join source, file
    if (yield is_directory path)
      if recursive
        yield (compile path, (join destination, file))
    else
      asset = Asset.create path
      mapping[asset.targetPath destination] = path
      try
        yield asset.write destination
      catch error
        console.log error
  # remove files that no longer have a corresponding source
  for file in (yield readdir destination)
    path = join destination, file
    if !(yield is_directory path)
      # every file in the destination directory should have a mapping
      # back to the original source. if the source file no longer exists
      # delete the generated destination file and the mapping
      if !(yield exists mapping[path])
        yield rm path
        delete mapping[path]

create = async (source, destination) ->
  # do an initial build, set up watchers and mtime cache
  yield clean destination
  yield compile source, destination
  (request, response, next) -> next()

  # supported_formats = keys Asset.formatsFor
  # async (request, response, next) ->
  #
  #
  #
  #   # You can only GET things from this middleware
  #   if request.method == "GET"
  #
  #     # Parse out the directory and filename
  #     path = URL.parse(request.url).pathname[1..]
  #     directory = join root, (dirname path)
  #     extension = extname path
  #     name = basename path, extension
  #     if name == "" then name = "index"
  #
  #     formats = if blank extension
  #       supported_formats
  #     else
  #       [(rest extension), supported_formats...]
  #
  #     acceptable = do (accept = accepts request)->
  #       (format) -> accept.type [format]
  #
  #     for format in (collect select acceptable, formats)
  #       assets = yield Asset.globNameForFormat directory, name, format
  #       if (asset = first assets)?
  #         response.setHeader 'content-type',
  #           (mime.contentType format) || (mime.contentType extension)
  #         if (content = (yield asset.render format)).pipe?
  #           content.pipe response
  #         else
  #           response.end content
  #         return
  #   next()

module.exports = {create}
