{go, map, tee, reject, include, Type, isType, Method, glob} = require "fairmont"

{define, context, coffee} = require "panda-9000"
{save, render} = Asset = require "../asset"
{pathWithUnderscore} = require "../utils"
Data = require "../data"

type = Type.define Asset

define "survey/coffee", ->
  {source} = require "../configuration"
  go [
    glob "**/*.coffee", source
    reject pathWithUnderscore
    map context source
    tee (context) -> Data.augment context
    tee ({target}) -> target.extension = ".js"
    map (context) -> include (Type.create type), context
    tee save
  ]

Method.define render, (isType type), coffee
