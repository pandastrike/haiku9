{go, map, tee, reject,
include, Type, isType, isMatch,
Method,
glob} = require "fairmont"

{define, context, sass} = require "panda-9000"
{save, render} = Asset = require "../asset"
{pathWithUnderscore} = require "../utils"

type = Type.define Asset

define "survey/sass", ->
  {source} = require "../configuration"
  go [
    glob "**/*.scss", source
    reject pathWithUnderscore
    map context source
    tee ({target}) -> target.extension = ".css"
    map (context) -> include (Type.create type), context
    tee save
  ]

Method.define render, (isType type), sass
