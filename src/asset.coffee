{read, readdir, async, collect, map, binary, curry} = require "fairmont"
{basename, extname, join} = require "path"
join = curry binary join
{attempt, promise} = require "when"
glob = require "panda-glob"
md2html = require "marked"
jade = require "jade"
stylus = require "stylus"
# C50N = require "c50n"
yaml = require "js-yaml"
CoffeeScript = require "coffee-script"

class Asset

  @read: async (path) -> new Asset path, (yield read path)

  @readFiles: async (files) ->
    for file in files
      yield Asset.read file

  @readDir: async (path) ->
    files = yield readdir path
    Asset.readFiles (collect map (join path), files)

  @glob: (path, pattern) ->
    files = glob path, pattern
    Asset.readFiles (collect map (join path), files)

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
    formats = @formatsFor[format]
    if formats?
      for format in [format, formats...]
        @extensionFor[format]
    else
      [format]

  @patternForFormat: (format, name="*") ->
    "#{name}.{#{@extensionsForFormat(format)},}"

  @globForFormat: (path, format) ->
    @glob path, @patternForFormat(format)

  @globNameForFormat: async (path, name, format) ->
    assets = yield Asset.glob path, Asset.patternForFormat(format, name)
    return v for k, v of assets
    throw new Error "Asset: No matching #{format} asset found
      for #{join(path, name)}"

  constructor: (@path, content) ->
    extension = extname @path
    @key = basename @path, extension
    @format = Asset.extensions[extension[1..]]
    divider = content.indexOf("\n---\n")
    if divider >= 0
      frontmatter = content[0...divider]
      try
        @data = yaml.safeLoad frontmatter
      catch error
        @data = {}
      @content = content[(divider+5)..]
    else
      @content = content

  render: (format, context = @context) ->
    formatter = Asset.formatters[@format]?[format]
    formatter ?= Asset.identityFormatter
    context ?= {}
    context.filename = @path
    formatter(@content, context)

Asset.registerExtension extension: "md", format: "markdown"
Asset.registerExtension extension: "jade", format: "jade"
Asset.registerExtension extension: "styl", format: "stylus"
Asset.registerExtension extension: "coffee", format: "coffeescript"
Asset.registerExtension extension: "js", format: "javascript"

Asset.identityFormatter = (content) ->
  promise (resolve, reject) ->
    resolve content

Asset.registerFormatter
  to: "html"
  from:  "markdown"
  (markdown) ->
    attempt(md2html,markdown)

Asset.registerFormatter
  to: "html"
  from:  "jade"
  (markup, context) ->
    context.cache = false
    attempt(jade.renderFile, context.filename, context)

Asset.registerFormatter
  to: "css"
  from:  "stylus"
  (code) ->
    attempt(stylus.render, code)

Asset.registerFormatter
  to: "javascript"
  from:  "coffeescript"
  (code) ->
    attempt(CoffeeScript.compile, code)

module.exports = Asset
