{go, tee, pull, async} = require "fairmont"
{task, writeFile} = require "panda-9000"

Asset = require "./asset"
{source, target} = require "./configuration"

task "build", "survey", async ->
  yield go [
    Asset.iterator()
    tee Asset.render
    pull
    tee writeFile target
  ]
