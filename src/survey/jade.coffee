{go, map, tee, reject,
include, Type, isType, isMatch,
Method,
glob} = require "fairmont"
{define} = Method
{task, context, jade} = require "panda-9000"
{save, render} = Asset = require "../asset"
Data = require "../data"
{pathWithUnderscore} = require "../utils"
{source} = require "../configuration"

type = Type.define Asset

task "survey/jade", "data", ->
  go [
    glob "**/*.jade", source
    reject pathWithUnderscore
    map context source
    tee (context) -> Data.augment context
    tee ({target}) -> target.extension = ".html"
    map (context) -> include (Type.create type), context
    tee save
  ]

define render, (isType type), jade
