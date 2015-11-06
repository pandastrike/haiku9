{go, map, tee, reject,
include, Type, isType, isMatch,
Method,
glob} = require "fairmont"
{define} = Method
{task, createContext, compileJade} = require "panda-9000"
{save, render} = Asset = require "../asset"
Data = require "../data"
{source} = require "../configuration"

type = Type.define Asset

task "survey/jade", "data", ->
  go [
    glob "**/*.jade", source
    reject (path) -> isMatch /(^|\/)_/, path
    map createContext source
    tee (context) -> Data.augment context
    tee ({target}) -> target.extension = ".html"
    map (context) -> include (Type.create type), context
    tee save
  ]

define render, (isType type), compileJade
