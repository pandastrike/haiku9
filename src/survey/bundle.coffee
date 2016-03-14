{join, dirname} = require "path"
{createWriteStream} = require "fs"
{go, map, tee, reject,
include, Type, isType, isMatch, async,
Method,
glob, read} = require "fairmont"

{define, context} = require "panda-9000"
browserify = require "browserify"
coffeeify = require "coffeeify"
{save, render} = Asset = require "../asset"
{source} = require "../configuration"

type = Type.define Asset

define "survey/bundle", ->
  go [
    glob "**/package.json", source
    reject isMatch /node_modules/
    map context source
    tee ({target}) -> target.extension = ".js"
    map (context) -> include (Type.create type), context
    tee async (asset) ->
      {name} = JSON.parse yield read asset.source.path
      asset.name = name
      asset.path = join (dirname dirname asset.path), name
    tee save
  ]

Method.define render, (isType type), async (asset) ->
  manifest = browserify()

  manifest.transform coffeeify,
    bare: false
    header: true

  yield go [
    yield glob "*.coffee", asset.source.directory
    map (path) -> manifest.add path
  ]
  yield go [
    yield glob "*.js", asset.source.directory
    map (path) -> manifest.add path
  ]

  # wrap Browserify's untyped stream in a ReadableStream
  {PassThrough} = require "stream"
  manifest.bundle()
  .on "error", (error) -> console.error error
  .pipe (asset.target.content = new PassThrough)
