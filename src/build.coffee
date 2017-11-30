{go, tee, pull, values, async, lift} = require "fairmont"
{define, write} = require "panda-9000"
rmrf = lift require "rimraf"

{render} = Asset = require "./asset"

define "build", ["survey"], async ->
  {source, target} = require "./configuration"
  yield rmrf target

  yield go [
    Asset.iterator()
    tee async (formats) ->
      yield go [
        values formats
        tee render
        pull
        tee write target
      ]
    pull
  ]
