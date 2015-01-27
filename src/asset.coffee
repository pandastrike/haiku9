FileSystem = require "fs"
{basename, extname, join} = require "path"
glob = require "panda-glob"
{promise, all, attempt} = require "when"
md2html = require "marked"
jade = require "jade"
stylus = require "stylus"
C50N = require "c50n"
CoffeeScript = require "coffee-script"

class Asset

  @read: (path) ->
    promise (resolve, reject) ->
      FileSystem.readFile path, encoding: "utf8", (error, content) ->
        unless error?
          resolve new Asset(path, content)
        else
          reject error

  @readFiles: (files) ->
    promise (resolve, reject) ->
      if files.length > 0
        all(
          for file in files
            Asset.read(file)
        )
        .then (assets) =>
          resolve assets
      else
        resolve []

  @readDir: (path) ->
    promise (resolve, reject) ->
      FileSystem.readdir path, (error, files) ->
        unless error?
          Asset.readFiles (join(path,file) for file in files)
          .then (assets) ->
            resolve assets
        else
          reject error

  @glob: (path, pattern) ->
    promise (resolve, reject) ->
      Asset.readFiles (join(path, file) for file in glob(path, pattern))
      .then (assets) ->
        resolve assets

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
    promise (resolve, reject) ->
      Asset.glob path, Asset.patternForFormat(format, name)
      .then (assets) ->
        keys = Object.keys(assets)
        if keys.length > 0
          key = keys[0]
          resolve assets[key]
        else
          reject(
            new Error "Asset: No matching #{format} asset found "
              +  " for #{join(path, name)}"
          )
      .catch (error) -> 
        reject error

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
        console.log error
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
    context.cache = true
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