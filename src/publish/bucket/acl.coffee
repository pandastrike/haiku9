{async} = require "fairmont"
config = require "../../configuration"

module.exports = (s3) ->

  # Set the access control permissions on the whole bucket.
  setACL: async ->
    try
      yield s3.putBucketAcl
        Bucket: config.s3.bucket
        ACL: "public-read"
    catch e
      console.error "Unexpected response while setting bucket permissions.", e
      throw new Error()
