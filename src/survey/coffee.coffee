{go, map, tee, include, Type, isType, Method, glob} = require "fairmont"
{define} = Method
{task, context, coffee} = require "panda-9000"
{save, render} = Asset = require "../asset"
{source} = require "../configuration"
Data = require "../data"

type = Type.define Asset

task "survey/coffee", ->
  go [
    glob "**/*.coffee", source
    map context source
    tee (context) -> Data.augment context
    tee ({target}) -> target.extension = ".js"
    map (context) -> include (Type.create type), context
    tee save
  ]

define render, (isType type), coffee
