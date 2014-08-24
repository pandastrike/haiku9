FileSystem = require "fs"
{basename, extname, join} = require "path"
glob = require "panda-glob"
Evie = require "evie"
md2html = require "marked"
jade = require "jade"
stylus = require "stylus"
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
      if files.length > 0
        do Asset.events.serially (go) ->
          go ->
            do Asset.events.concurrently (go) ->
              for file in files
                do (file) ->
                  go file, -> Asset.read(file)
          go (assets) ->
            events.emit "success", assets
      else
        events.emit "success", []

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

  @patternForFormat: (format, name="*") ->
    "#{name}.{#{@extensionsForFormat(format)},}"

  @globForFormat: (path, format) ->
    @glob path, @patternForFormat(format)

  @globNameForFormat: (path, name, format) ->
    @events.source (events) ->
      Asset.glob path, Asset.patternForFormat(format, name)
      .success (assets) ->
        keys = Object.keys(assets)
        if keys.length > 0
          key = keys[0]
          events.emit "success", assets[key]
        else
          events.emit "error",
            new Error "Asset: No matching #{format} asset found "
              +  " for #{join(path, name)}"
      .error (error) -> events.emit error

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
    formatter = Asset.formatters[@format]?[format]
    formatter ?= Asset.identityFormatter
    formatter(@content, context)

Asset.registerExtension extension: "md", format: "markdown"
Asset.registerExtension extension: "jade", format: "jade"
Asset.registerExtension extension: "styl", format: "stylus"

Asset.identityFormatter = (content) ->
  Asset.events.source (events) ->
    events.emit "success", content

Asset.registerFormatter
  to: "html"
  from:  "markdown"
  (markdown) ->
    Asset.events.source (events) ->
      events.safely ->
        events.emit "success", md2html(markdown)

Asset.registerFormatter
  to: "html"
  from:  "jade"
  (markup, context) ->
    Asset.events.source (events) ->
      events.safely ->
        render = jade.compile(markup)
        events.emit "success", render(context)

Asset.registerFormatter
  to: "css"
  from:  "stylus"
  (code) ->
    Asset.events.source (events) ->
      events.safely ->
        stylus.render code, events.callback

module.exports = Asset
