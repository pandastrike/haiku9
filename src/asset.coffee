FileSystem = require "fs"
{extname, join} = require "path"
glob = require "panda-glob"
Evie = require "evie"
md2html = require "marked"

class Asset

  @events: new Evie

  @read: (path) ->
    @events.source (events) ->
      FileSystem.readFile path, encoding: "utf8", (error, content) ->
        unless error?
          events.emit "success", new Asset(path, content)
        else
          events.emit "error", error

  @readFiles: (files) ->
    @events.source (events) ->
      do Asset.events.serially (go) ->
        go ->
          do Asset.events.concurrently (go) ->
            for file in files
              go file, -> Asset.read(file)
        go (assets) ->
          events.emit "success", assets

  @readDir: (path) ->
    @events.source (events) ->
      FileSystem.readdir path, (error, files) ->
        unless error?
          Asset.readFiles (join(path,file) for file in files)
          .forward events
        else
          events.emit "error", error

  @glob: (path, pattern) ->
    @events.source (events) ->
      events.safely ->
        Asset.readFiles (join(path, file) for file in glob(path, pattern))
        .forward events

  @registerFormatter: ({to, from}, formatter) ->
    @formatters ?= {}
    @formatters[from] ?= {}
    @formatters[from][to] = formatter

  constructor: (@path, @content) ->
    @format = Asset.extensions[(extname @path)[1..]]

  render: (format, context = @context) ->
    Asset.formatters[@format]?[format]?(@content, @context)

Asset.extensions =
  md: "markdown"

Asset.registerFormatter
  to: "html"
  from:  "markdown"
  (markdown) ->
    Asset.events.source (events) ->
      events.emit "success", md2html(markdown)


module.exports = Asset
