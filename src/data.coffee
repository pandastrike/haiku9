{sep} = require "path"
{curry, go, map, tee, async, include, read, glob} = require "fairmont"
{task, createContext} = require "panda-9000"
yaml = require "js-yaml"
loadYAML = async (path) -> yaml.safeLoad yield read path
{source} = require "./configuration"

Data =

  root: {}

  set: curry (path, value) ->
    head = Data.root
    [keys..., name] = path.split sep
    for key in keys when key != "."
      head[key] ?= {}
      head = head[key]
    head[name] = value

  get: (path) ->
    head = Data.root
    keys = path.split sep
    for key in keys when key != "."
      head = head[key]
      break unless head?
    head

  augment: (asset) ->
    include asset.data, Data.root, Data.get asset.path

task "data", async ->
  yield go [
    glob "**/*.yaml", source
    map createContext source
    tee async (context) ->
      context.path = context.path.replace /(^|\/)_/, "$1"
      Data.set context.path, yield loadYAML context.source.path
  ]

module.exports = Data
