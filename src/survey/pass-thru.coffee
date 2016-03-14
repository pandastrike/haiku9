{createReadStream} = require "fs"
{go, map, tee, reject,
w, include, Type, isType, isMatch, Method,
glob} = require "fairmont"

{define, context} = require "panda-9000"
{save, render} = Asset = require "../asset"
{pathWithUnderscore} = require "../utils"
{source} = require "../configuration"

formats = w ".html .css .js .woff .ttf"

type = Type.define Asset

define "survey/pass-thru", ->
  go [
    glob "**/*{#{formats.join ','}}", source
    reject pathWithUnderscore
    map context source
    tee ({source, target}) -> target.extension = source.extension
    map (context) -> include (Type.create type), context
    tee save
  ]

Method.define render, (isType type), ({source, target}) ->
  target.content = createReadStream source.path
