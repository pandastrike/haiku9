{include, read, read_buffer, write, readdir, async, keys,
  first, rest, collect, map, binary, curry} = require "fairmont"
{createReadStream} = require "fs"
{dirname, basename, extname, join, resolve} = require "path"
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

  @formatterFor: (source, target) ->
    formatter = Asset.formatters[source]?[target]
    formatter ?= Asset.identityFormatter

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
    @extension = rest extension
    @key = basename @path, extension
    @format = Asset.extensions[@extension]
    @format ?= @extension
    @target = {}
    formatters = Asset.formatters[@format]
    @supportedFormats = if formatters? then keys formatters else [@format]
    @target.format = first @supportedFormats
    @target.extension = Asset.extensionFor[@target.format]
    @target.extension ?= @target.format

  targetPath: (path) ->
    if @target.extension?
      join path, "#{@key}.#{@target.extension}"
    else
      join path, @key

  write: async (path) ->
    write (@targetPath path), yield @render()

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

  render: ->
    ((Asset.formatterFor @format, @target.format) @)


Asset.registerExtension extension: "md", format: "markdown"
Asset.registerExtension extension: "jade", format: "jade"
Asset.registerExtension extension: "styl", format: "stylus"
Asset.registerExtension extension: "coffee", format: "coffeescript"
Asset.registerExtension extension: "js", format: "javascript"

Asset.identityFormatter = async ({path}) -> yield read_buffer path

Asset.registerFormatter
  to: "html"
  from:  "markdown"
  async (asset) -> # md2html yield read asset.path
    if !asset.renderer?
      directory = dirname asset.path
      layout = "_layout"
      until layout.length > 13 || "_layout.jade" in (yield readdir directory)
        directory = resolve directory, ".."
        layout = join "..", layout
      html = (md2html (yield read asset.path))
        .replace /#\{/gm, "&num;{"
        .replace /\n/gm, "\n    "
      template = """
        extends #{layout}
        block content
          :verbatim
            #{html}
      """
      asset.renderer = jade.compile template,
        cache: false, filename: asset.path
    try
      asset.renderer asset.context
    catch error
      # we ignore the Jade error since it references the markdown
      # instead of our generated file. we could dump the template
      # file and re-run the processor, but that still isn't very
      # useful--Jade doesn't 'see into' filters.
      console.log error
      throw "Unable to render markdown in #{asset.path}"

Asset.registerFormatter
  to: "html"
  from:  "jade"
  (asset) ->
    {path} = asset
    asset.renderer ?= jade.compileFile path, cache: false
    asset.renderer asset.context

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
