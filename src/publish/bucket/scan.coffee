{async, collect, pull} = require "fairmont"

# Establishes what objects already exist up in S3.
module.exports = (config, s3) ->
  bucket = require("./s3")(s3)

  async ->
    # Search your buckets for all hostnames. If they don't exist, make them.
    console.log "Scanning S3 bucket."
    exists = (bucket.establish name for name in config.aws.hostnames)
    yield collect pull exists

    if exists[0]
      # The main buckets already exists.  Scan for objects and their md5 hashes.
      yield bucket.setACL config.aws.hostnames[0]
      yield bucket.list config.aws.hostnames[0], {}
    else
      # A new bucket was created, return an empty object
      {}
