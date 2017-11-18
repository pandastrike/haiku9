{go, map, tee, reject,
include, Type, isType, isMatch,
Method, rest, last,
glob} = require "fairmont"

{define, context} = require "panda-9000"
{save, render} = Asset = require "../asset"
Data = require "../data"
{pathWithUnderscore, isBowerComponentsPath} = require "../utils"

type = Type.define Asset

define "survey/pug", ["data"], ->
  {source} = require "../configuration"
  go [
    glob "**/*.+(pug|jade)", source
    reject pathWithUnderscore
    reject isBowerComponentsPath
    map context source
    tee (context) -> Data.augment context
    tee ({target}) -> target.extension = ".html"
    map (context) -> include (Type.create type), context
    tee save
  ]

Method.define render, (isType type), (asset) ->
  {source} = require "../configuration"
  pug = require("./helpers/pug")(source)

  # Generate a useful value for the file's path.  Add to _h9 dictionary.
  path = asset.source.path.split("/")
  if last(path) == "index.pug" || last(path) == "index.jade"
    path = path.slice(0, path.length - 1) # Drop the final piece from the path.
  else
    # Drop the file extension.
    path[path.length - 1] = last(path).replace(asset.source.extension, "")
  path = "/" + rest(path).join("/")

  asset.data._h9 = {path}
  pug asset
