{async} = require "fairmont"

config = require "../../configuration"


module.exports = (s3) ->

  # Sets the S3 bucket's static site configuration.
  enable: async ->
    params =
      Bucket: config.s3.bucket
      WebsiteConfiguration:
        ErrorDocument:
          Key: config.s3.web.error.toString()
        IndexDocument:
          Suffix: config.s3.web.index.toString()

    try
      yield s3.putBucketWebsite params
    catch e
      console.error "Unexpected reply while setting bucket's site config", e
      throw new Error()
