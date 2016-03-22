{iterator, values, first, Method, Type, include} = require "fairmont"

Asset = Type.define()

_assets = {}

include Asset,

  dictionary: _assets

  iterator: ->
    iterator values _assets

  find: ({path, extension}) ->
    if (rx = _assets[path])?
      if !extension
        first values rx
      else
        rx[extension]

  save: (asset) ->
    _assets[asset.path] ?= {}
    _assets[asset.path][asset.target.extension] = asset

  render: Method.create()

module.exports = Asset
