{include, read, readdir, async,
  collect, map, binary, curry} = require "fairmont"
{createReadStream} = require "fs"
{basename, extname, join} = require "path"
join = curry binary join
{attempt, promise} = require "when"
glob = require "panda-glob"
md2html = require "marked"
jade = require "jade"
stylus = require "stylus"
yaml = require "js-yaml"
CoffeeScript = require "coffee-script"


class Asset

  @create: (path) -> new Asset path

  @map: (paths) ->
    (Asset.create path) for path in paths

  @readDir: async (path) ->
    files = yield readdir path
    Asset.map (collect map (join path), files)

  @glob: (path, pattern) ->
    files = glob path, pattern
    Asset.map (collect map (join path), files)

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
    @patternForFormats [format], name

  @patternForFormats: (formats, name="*") ->
    extensions = map (format) => @extensionsForFormat format
    "#{name}.{#{collect extensions formats},}"

  @globNameForFormat: (path, name, formats...) ->
     Asset.glob path, Asset.patternForFormats formats, name

  constructor: (@path) ->
    extension = extname @path
    @key = basename @path, extension
    @format = Asset.extensions[extension[1..]]
    @context = {}

    # divider = content.indexOf("\n---\n")
    # if divider >= 0
    #   frontmatter = content[0...divider]
    #   try
    #     @data = yaml.safeLoad frontmatter
    #   catch error
    #     @data = {}
    #   @content = content[(divider+5)..]
    # else
    #   @content = content

  render: (format, context) ->
    formatter = Asset.formatters[@format]?[format]
    formatter ?= Asset.identityFormatter
    include @context, context
    formatter @

Asset.registerExtension extension: "md", format: "markdown"
Asset.registerExtension extension: "jade", format: "jade"
Asset.registerExtension extension: "styl", format: "stylus"
Asset.registerExtension extension: "coffee", format: "coffeescript"
Asset.registerExtension extension: "js", format: "javascript"

Asset.identityFormatter = ({path}) -> createReadStream path

Asset.registerFormatter
  to: "html"
  from:  "markdown"
  ({content}) -> md2html content

Asset.registerFormatter
  to: "html"
  from:  "jade"
  ({path, context}) ->
    context.cache = false
    jade.renderFile path, context

Asset.registerFormatter
  to: "css"
  from:  "stylus"
  async ({path}) ->
    stylus (yield read path)
    .set "filename", path
    .render()

Asset.registerFormatter
  to: "javascript"
  from:  "coffeescript"
  async ({path}) ->
    CoffeeScript.compile (yield read path)

module.exports = Asset
