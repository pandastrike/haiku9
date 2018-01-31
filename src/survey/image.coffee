# TODO: for now, these are just the same as the pass-thru assets
# but the idea is to add on-the-fly image optimization

{createReadStream} = require "fs"
{go, map, tee, reject,
w, include, Type, isType, Method,
glob} = require "fairmont"

{define, context} = require "panda-9000"
{save, render} = Asset = require "../asset"
{pathWithUnderscore} = require "../utils"

formats = w ".jpg .jpeg .png .webp .svg .gif .ico"

type = Type.define Asset

define "survey/image", ->
  {source} = require "../configuration"
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
