# Publish pushes the site to the AWS cloud platform.
{async, empty} = require "fairmont"
{task} = require "panda-9000"

task "publish", async ->
  bucket = yield require "./bucket"
  local = require "./local"

  remoteFiles = yield bucket.scan()
  localFiles = yield local.scan()

  actions = local.reconcile localFiles, remoteFiles
  yield bucket.sync actions
