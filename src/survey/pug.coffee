{go, map, tee, reject,
include, Type, isType, isMatch,
Method,
glob} = require "fairmont"

{define, context, pug} = require "panda-9000"
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

Method.define render, (isType type), pug
