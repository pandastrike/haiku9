# Publish pushes the site to the AWS cloud platform.
{async, empty} = require "fairmont"
{task} = require "panda-9000"

config = require "../configuration"

task "publish", async ->
  bucket = yield require "./bucket"
  local = require "./local"

  remoteFiles = yield bucket.scan()
  localFiles = yield local.scan()

  actions = local.reconcile localFiles, remoteFiles
  yield bucket.sync actions

  yield bucket.web.enable()

  # If the user requests a CloudFront CDN distribution,
  if config.s3.cloudFront
    distribution = yield bucket.cf.set()
    yield bucket.cf.sync distribution, actions

  changeID = yield bucket.dns.set distribution
  yield bucket.dns.sync changeID
