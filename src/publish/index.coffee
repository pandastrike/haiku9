# Publish pushes the site to the AWS cloud platform.
{async, empty} = require "fairmont"
{define} = require "panda-9000"

define "publish", async (env, options) ->
  config = require("../configuration/publish")(env)

  bucket = yield require("./bucket")(config)
  local = require "./local"

  remoteFiles = yield bucket.scan()
  localFiles = yield local.scan()

  config.force = options.force
  actions = local.reconcile localFiles, remoteFiles, config
  yield bucket.sync actions

  yield bucket.web.enable()

  # If the user requests a CloudFront CDN distribution,
  if config.aws.cache
    distributions = yield bucket.cf.set()
    yield bucket.cf.sync distributions, actions

  changeID = yield bucket.dns.set distributions
  yield bucket.dns.sync changeID
