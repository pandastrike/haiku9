{iterator, values, Method, Type, include} = require "fairmont"

Asset = Type.define()

_assets = {}

include Asset,

  dictionary: _assets

  iterator: -> iterator values _assets

  find: ({path, extension}) ->
    if (asset = _assets[path])?
      if !extension? || (asset.target.extension == extension)
        asset

  save: (asset) -> _assets[asset.path] = asset

  render: Method.create()

module.exports = Asset
