marked = require "marked"
{go, map, tee, reject, async, include,
Type, isType, Method, glob, read} = require "fairmont"

{define, context, pug} = require "panda-9000"
{save, render} = Asset = require "../asset"
Data = require "../data"
{pathWithUnderscore, isBowerComponentsPath} = require "../utils"

type = Type.define Asset

define "survey/markdown", ["data"], ->
  {source} = require "../configuration"
  go [
    glob "**/*.md", source
    reject pathWithUnderscore
    reject isBowerComponentsPath
    map context source
    tee (context) -> Data.augment context
    tee ({target}) -> target.extension = ".html"
    map (context) -> include (Type.create type), context
    tee save
  ]

Method.define render, (isType type), async (asset) ->
  markdown = (yield read asset.source.path)
    .replace /\n/gm, "\n    "
    .replace /\#\{/g, '\\#{'
  asset.source.content = """
    extends _layout
    block content
      :markdown-it
        #{markdown}
  """
  pug asset
