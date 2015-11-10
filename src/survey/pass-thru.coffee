{createReadStream} = require "fs"
{go, map, tee, reject,
w, include, Type, isType, isMatch, Method,
glob} = require "fairmont"
{define} = Method
{task, context} = require "panda-9000"
{save, render} = Asset = require "../asset"
{source} = require "../configuration"

formats = w ".css .js"

type = Type.define Asset

task "survey/pass-thru", ->
  go [
    glob "**/*{#{formats.join ','}}", source
    reject (path) -> isMatch /(^|\/)_/, path
    map context source
    tee ({source, target}) -> target.extension = source.extension
    map (context) -> include (Type.create type), context
    tee save
  ]

define render, (isType type), ({source, target}) ->
  target.content = createReadStream source.path
