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
mapping = {}
compile = async (source, destination, recursive = true, watching = true) ->
  log.info "Compiling [ #{source} ] ..."
  yield mkdirp "0777", destination
  if watching
    log.info "Watching [ #{source} ] ..."
    watch source, async ->
      # we only know something in this directory changed, so we don't
      # need to compile recursively, nor do we need to set up watchers
      # again...
      yield compile source, destination, false, false
  files = yield readdir source
  for file in files when file[0] != "_"
    path = join source, file
    if (yield is_directory path)
      if recursive
        yield (compile path, (join destination, file), true, watching)
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

module.exports = {compile, clean}
