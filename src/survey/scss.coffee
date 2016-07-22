{go, map, tee, reject,
include, Type, isType,
Method,
glob} = require "fairmont"

{define, context, sass} = require "panda-9000"
{save, render} = Asset = require "../asset"
{pathWithUnderscore} = require "../utils"

type = Type.define Asset

define "survey/scss", ->
  {source} = require "../configuration"
  go [
    # node-sass only supports SCSS
    # https://github.com/sass/libsass/issues/16
    glob "**/*.scss", source
    reject pathWithUnderscore
    map context source
    tee ({target}) -> target.extension = ".css"
    map (context) -> include (Type.create type), context
    tee save
  ]

Method.define render, (isType type), sass
