{go, map, tee, reject,
include, Type, isType, isMatch,
Method,
glob} = require "fairmont"

{define, context, jade} = require "panda-9000"
{save, render} = Asset = require "../asset"
Data = require "../data"
{pathWithUnderscore} = require "../utils"

type = Type.define Asset

define "survey/jade", ["data"], ->
  {source} = require "../configuration"
  go [
    glob "**/*.jade", source
    reject pathWithUnderscore
    map context source
    tee (context) -> Data.augment context
    tee ({target}) -> target.extension = ".html"
    map (context) -> include (Type.create type), context
    tee save
  ]

Method.define render, (isType type), jade
