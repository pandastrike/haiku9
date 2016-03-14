marked = require "marked"
{go, map, tee, reject, async, include,
Type, isType, Method, glob, read} = require "fairmont"

{define, context, jade} = require "panda-9000"
{save, render} = Asset = require "../asset"
Data = require "../data"
{pathWithUnderscore} = require "../utils"
{source} = require "../configuration"

type = Type.define Asset

define "survey/markdown", ["data"], ->
  go [
    glob "**/*.md", source
    reject pathWithUnderscore
    map context source
    tee (context) -> Data.augment context
    tee ({target}) -> target.extension = ".html"
    map (context) -> include (Type.create type), context
    tee save
  ]

Method.define render, (isType type), async (asset) ->
  do (source) ->
    {source} = asset
    markdown = (yield read source.path)
      .replace /\n/gm, "\n    "
      .replace /\#\{/g, '\\#{'
    source.content = """
      extends _layout
      block content
        :markdown
          #{markdown}
    """
    jade asset
