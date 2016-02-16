# Publish pushes the site to the AWS cloud platform.
{async, empty} = require "fairmont"
{task} = require "panda-9000"

task "publish", async ->
  bucket = yield require "./bucket"
  local = require "./local"

  bucket.preflight()

  console.log "Scanning S3 bucket."
  remoteFiles = yield bucket.scan()
  console.log "Scanning local repo."
  localFiles = yield local.scan()

  console.log "Syncing S3 bucket."
  actions = local.reconcile localFiles, remoteFiles
  yield bucket.sync actions

  console.log "Configuring S3 bucket static serving."
  yield bucket.web.enable()

  console.log "Setting up DNS record to point to S3 bucket."
  changeID = yield bucket.dns.set()

  if changeID
    console.log "Waiting for DNS records to synchronize."
  else
    console.log "DNS up to date.  Skipping."
  yield bucket.dns.sync changeID if changeID
