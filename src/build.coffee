{go, tee, pull, values, async} = require "fairmont"
{define, write} = require "panda-9000"
{lift} = require "when/node"
rmrf = lift require "rimraf"

{render} = Asset = require "./asset"
{source, target} = require "./configuration"

define "build", ["survey"], async ->

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
  ]
