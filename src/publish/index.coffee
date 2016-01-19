# Publish pushes the site to the AWS cloud platform.
{async, empty} = require "fairmont"
{task} = require "panda-9000"

{scanLocal, reconcile} = require "./hash"

task "publish", async ->
  s3 = yield require "./s3"

  remoteFiles = yield s3.scanBucket()
  localFiles = yield scanLocal()

  tasks = reconcile localFiles, remoteFiles
  yield s3.syncBucket tasks
