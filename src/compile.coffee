{watch} = require "fs"
{basename, extname, join} = require "path"
YAML = require "js-yaml"
{async, mkdirp, read, readdir, is_directory, rmdir, rm,
  stat, exists} = require "fairmont"
log = (require "log4js").getLogger("h9")
Asset = require "./asset"

clean = async ({target, recursive}) ->
  recursive ?= true
  if yield exists target
    files = yield readdir target
    for file in files
      path = join target, file
      if (yield is_directory path)
        (yield clean target: path) if recursive
      else
        yield rm path
    (yield rmdir target) if recursive

mapping = {}
data = undefined
compile = async ({source, target, recursive, watching}) ->
  recursive ?= true
  watching ?= true
  data ?= yield compileData {root: {}, source, recursive, watching}
  log.info "Compiling [ #{source} ] ..."
  yield mkdirp "0777", target
  if watching
    log.info "Watching [ #{source} ] ..."
    watch source, async ->
      # we only know something in this directory changed, so we don't
      # need to compile recursively, nor do we need to set up watchers
      # again...
      yield compile {source, target, recursive: false, watching: false}
  files = yield readdir source
  for file in files when (file[0] != "_" && file[0] != ".")
    path = join source, file
    if (yield is_directory path)
      if recursive
        yield compile
          source: path
          target: (join target, file)
          recursive: true
          watching: watching
    else
      asset = Asset.create path
      mapping[asset.targetPath target] = path
      try
        asset.context = public: data
        yield asset.write target
      catch error
        log.error error
  # remove files that no longer have a corresponding source
  for file in (yield readdir target)
    path = join target, file
    if !(yield is_directory path)
      # every file in the target directory should have a mapping
      # back to the original source. if the source file no longer exists
      # delete the generated target file and the mapping
      if !(yield exists mapping[path])
        yield rm path
        delete mapping[path]

compileData = async ({root, source, watching, recursive}) ->
  if watching
    watch source, ->
      compileData {root, source, watching: false, recursive: false}
  for file in (yield readdir source)
    path = join source, file
    if (yield is_directory path)
      if recursive
        yield compileData
          root: (root[file] ?= {})
          source: path
          watching: watching
          recursive: true
    else
      extension = extname file
      key = basename file, extension
      if extension == ".yml" || extension == ".yaml"
        root[key] = YAML.safeLoad (yield read path)
  root

module.exports = {compile, clean}
