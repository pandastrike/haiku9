{go, map, tee, reject,
include, Type, isType,
Method,
glob} = require "fairmont"

{define, context, handlebars} = require "panda-9000"
{save, render} = Asset = require "../asset"
Data = require "../data"
{pathWithUnderscore} = require "../utils"

type = Type.define Asset

define "survey/handlebars", ["data"], ->
  {source} = require "../configuration"
  go [
    glob "**/*.{hb,hbs,handlebars}", source
    reject pathWithUnderscore
    map context source
    tee (context) -> Data.augment context
    tee ({target}) -> target.extension = ".html"
    map (context) -> include (Type.create type), context
    tee save
  ]

Method.define render, (isType type), handlebars
