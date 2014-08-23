FileSystem = require "fs"
{basename, extname, join} = require "path"
glob = require "panda-glob"
Evie = require "evie"
md2html = require "marked"
jade = require "jade"
C50N = require "c50n"

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
              do (file) ->
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
    @formatsFor ?= {}
    @formatsFor[to] ?= []
    @formatsFor[to].push from

  @registerExtension: ({extension, format}) ->
    Asset.extensions ?= {}
    Asset.extensions[extension] = format
    Asset.extensionFor ?= {}
    Asset.extensionFor[format] = extension

  @extensionsForFormat: (format) ->
    for format in @formatsFor[format]
      @extensionFor[format]

  @patternForFormat: (format) ->
    "*.{#{@extensionsForFormat(format)}}"

  @globForFormat: (path, format) ->
    @glob path, @patternForFormat(format)

  constructor: (@path, content) ->
    extension = extname @path
    @key = basename @path, extension
    @format = Asset.extensions[extension[1..]]
    divider = content.indexOf("\n---\n")
    if divider >= 0
      frontmatter = content[0..(divider-1)]
      try
        @data = C50N.parse(frontmatter)
      catch error
        Asset.events.emit "error", error
      @content = content[(divider+5)..]
    else
      @content = content

  render: (format, context = @context) ->
    Asset.formatters[@format]?[format]?(@content, @context)

Asset.registerExtension extension: "md", format: "markdown"
Asset.registerExtension extension: "jade", format: "jade"

Asset.registerFormatter
  to: "html"
  from:  "markdown"
  (markdown) ->
    Asset.events.source (events) ->
      events.emit "success", md2html(markdown)

Asset.registerFormatter
  to: "html"
  from:  "jade"
  (markup, context) ->
    Asset.events.source (events) ->
      events.emit "success", jade.compile(markup)(context)

module.exports = Asset
