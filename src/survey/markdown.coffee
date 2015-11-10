marked = require "marked"
{go, map, tee, async, include,
Type, isType, Method, glob, read} = require "fairmont"
{define} = Method
{task, context, jade} = require "panda-9000"
{save, render} = Asset = require "../asset"
Data = require "../data"
{source} = require "../configuration"

type = Type.define Asset

task "survey/markdown", "data", ->
  go [
    glob "**/*.md", source
    map context source
    tee (context) -> Data.augment context
    tee ({target}) -> target.extension = ".html"
    map (context) -> include (Type.create type), context
    tee save
  ]

define render, (isType type), async (asset) ->
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
