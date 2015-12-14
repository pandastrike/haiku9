{go, map, tee, reject, include, Type, isType, Method, glob} = require "fairmont"
{define} = Method
{task, context, coffee} = require "panda-9000"
{save, render} = Asset = require "../asset"
{pathWithUnderscore} = require "../utils"
{source} = require "../configuration"
Data = require "../data"

type = Type.define Asset

task "survey/coffee", ->
  go [
    glob "**/*.coffee", source
    reject pathWithUnderscore
    map context source
    tee (context) -> Data.augment context
    tee ({target}) -> target.extension = ".js"
    map (context) -> include (Type.create type), context
    tee save
  ]

define render, (isType type), coffee
