{async, rest, sleep} = require "fairmont"

config = require "../../configuration"

# Establishes what objects already exist up in S3.
module.exports = (s3) ->
  bucket = require("./s3")(s3)

  async ->
    # Search your buckets for all hostnames. If they don't exist, make them.
    console.log "Scanning S3 bucket."
    exists = yield bucket.establish config.s3.hostnames[0]
    yield bucket.establish name for name in rest config.s3.hostnames

    if exists
      # The main buckets already exists.  Scan for objects and their md5 hashes.
      yield bucket.setACL config.s3.hostnames[0]
      yield bucket.list config.s3.hostnames[0], {}
    else
      # A new bucket was created, return an empty object
      yield sleep 5000
      {}
