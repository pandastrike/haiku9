{go, map, tee, reject,
include, Type, isType, isMatch,
Method,
glob} = require "fairmont"

{define, context, stylus} = require "panda-9000"
{save, render} = Asset = require "../asset"
{pathWithUnderscore} = require "../utils"
{source} = require "../configuration"

type = Type.define Asset

define "survey/stylus", ->
  go [
    glob "**/*.styl", source
    reject pathWithUnderscore
    map context source
    tee ({target}) -> target.extension = ".css"
    map (context) -> include (Type.create type), context
    tee save
  ]

Method.define render, (isType type), stylus
