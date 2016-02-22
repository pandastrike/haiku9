{async} = require "fairmont"

config = require "../../configuration"

# Establishes what objects already exist up in S3.
module.exports = (s3) ->
  {listObjects} = require("./helpers")(s3)
  {setACL} = require("./acl")(s3)


  async ->
    # Search your buckets to see if it exists.  If it doesn't, create it.
    console.log "Scanning S3 bucket."
    try
      match = yield s3.headBucket Bucket: config.s3.bucket
    catch e
      switch e.statusCode
        when 301
          console.error "The bucket is in a different region than the client " +
            "is currently configured to target. Correct the region in your " +
            ".h9 file."
          throw new Error()
        when 403
          console.error "You are not authorized to modify this bucket."
          throw new Error()
        when 404 then match = false
        else
          console.error "Unexpected reply from AWS", e
          throw new Error()


    if !match
      # Create a new, empty S3 bucket. Return an empty hash of objects.
      try
        yield s3.createBucket
          Bucket: config.s3.bucket
          ACL: "public-read"
        {}
      catch e
        console.error "Failed to establish bucket.", e
        throw new Error()
    else
      # We found an existing bucket.  Scan it for objects and their md5 hashes.
      yield setACL()
      yield listObjects {}
