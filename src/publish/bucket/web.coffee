{async, rest} = require "fairmont"

config = require "../../configuration"


module.exports = (s3) ->

  # Sets the S3 bucket's static site configuration.
  enable: async ->
    console.log "Configuring S3 bucket for static serving."
    params =
      Bucket: config.s3.hostnames[0]
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


    for name in rest config.s3.hostnames
      params =
        Bucket: name
        WebsiteConfiguration:
          RedirectAllRequestsTo:
            HostName: config.s3.hostnames[0]
            Protocol: if config.s3.cloudFront?.ssl then "https" else "http"

      try
        yield s3.putBucketWebsite params
      catch e
        console.error "Unexpected reply while setting bucket's site config", e
        throw new Error()
