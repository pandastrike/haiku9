{go, tee, pull, async} = require "fairmont"
{task, writeFile} = require "panda-9000"
{lift} = require "when/node"
rmrf = lift require "rimraf"

Asset = require "./asset"
{source, target} = require "./configuration"

task "build", "survey", async ->

  yield rmrf target

  yield go [
    Asset.iterator()
    tee Asset.render
    pull
    tee writeFile target
  ]
