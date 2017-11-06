{async, collect, pull} = require "fairmont"

# Establishes what objects already exist up in S3.
module.exports = (config, s3) ->
  bucket = require("./s3")(s3)

  async ->
    # Search your buckets for all hostnames. If they don't exist, make them.
    console.log "-- Scanning S3 bucket."
    exists = (bucket.establish(name, config.aws.cors) for name in config.aws.hostnames)
    yield collect pull exists

    # If the primary bucket already existed, scan its objects and their md5 hashes.
    if exists[0]
      yield bucket.list config.aws.hostnames[0], {}
    else
      {}  # The primary bucket is a new and therefore empty.
