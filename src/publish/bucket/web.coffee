{async, rest} = require "fairmont"

config = require "../../configuration"


module.exports = (config, s3) ->

  # Sets the S3 bucket's static site configuration.
  enable: async ->
    console.log "Configuring S3 bucket for static serving."
    params =
      Bucket: config.aws.hostnames[0]
      WebsiteConfiguration:
        ErrorDocument:
          Key: config.aws.site.error.toString()
        IndexDocument:
          Suffix: config.aws.site.index.toString()

    try
      yield s3.putBucketWebsite params
    catch e
      console.error "Unexpected reply while setting bucket's site config", e
      throw new Error()


    for name in rest config.aws.hostnames
      params =
        Bucket: name
        WebsiteConfiguration:
          RedirectAllRequestsTo:
            HostName: config.aws.hostnames[0]
            Protocol: if config.aws.cache?.ssl then "https" else "http"

      try
        yield s3.putBucketWebsite params
      catch e
        console.error "Unexpected reply while setting bucket's site config", e
        throw new Error()
