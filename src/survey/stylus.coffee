{go, map, tee, reject,
include, Type, isType, isMatch,
Method,
glob} = require "fairmont"
{define} = Method
{task, createContext, compileStylus} = require "panda-9000"
{save, render} = Asset = require "../asset"
{source} = require "../configuration"

type = Type.define Asset

task "survey/stylus", ->
  go [
    glob "**/*.styl", source
    reject (path) -> isMatch /(^|\/)_/, path
    map createContext source
    tee ({target}) -> target.extension = ".css"
    map (context) -> include (Type.create type), context
    tee save
  ]

define render, (isType type), compileStylus
