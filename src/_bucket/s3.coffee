{async, sleep, isArray} = require "fairmont"

module.exports = (s3) ->

  establish = async (name, cors) ->
    try
      exists = yield s3.headBucket Bucket: name
    catch e
      switch e.statusCode
        when 301
          console.error "The bucket is in a different region than the client " +
            "is currently configured to target. Correct the region in your " +
            ".h9 file."
          throw new Error()
        when 403
          console.error "You are not authorized to modify this bucket."
          throw e
        when 404
          exists = false
        else
          console.error "Unexpected reply from AWS", e
          throw e

    # If the bucket already exists: ensure it is properly configured.
    if exists
      yield setACL name
      yield setCORS name, cors if cors
      return true

    # If the bucket does not exist: create a new, empty S3 bucket.
    # There is a grace period to wait for bucket to be available to API.
    # TODO: Fix by using CloudFormation to do setup instead.
    try
      yield s3.createBucket {Bucket: name, ACL: "public-read"}
      yield sleep 15000
      yield setCORS name, cors if cors
      return false
    catch e
      console.error "Failed to establish bucket.", e
      throw new Error()


  # Recursive method to grab all of the object headers in an S3 bucket
  list = async (name, objects, marker) ->
    # Helper to extract data from object header list and creates a lookup table.
    catTable = (table, data) ->
      for obj in data
        table[obj.Key] =
          hash: obj.ETag.split("\"")[1]
          size: obj.Size
      table

    try
      params =
        Bucket: name,
        Delimiter: '#'
        MaxKeys: 1000

      params["Marker"] = marker if marker
      data = yield s3.listObjects params

      if data.IsTruncated
        objects = catTable objects, data.Contents
        yield list name, objects, data.NextMarker
      else
        catTable objects, data.Contents
    catch e
      console.error "Unexpected reply while pulling S3 bucket keys.", e
      throw new Error()


  # Set the access control permissions on the whole bucket.
  setACL = async (name) ->
    try
      yield s3.putBucketAcl {Bucket: name, ACL: "public-read"}
    catch e
      console.error "Unexpected response while setting bucket permissions.", e
      throw new Error()


  buildRule = (c) ->
    {allowedHeaders = ["*"], allowedMethods = ["GET"], allowedOrigins = ["*"], exposedHeaders = [""]} = c
    maxAge = c.maxAge if c.maxAge? # This may be configured to zero for no-cache

    rule =
      AllowedHeaders: allowedHeaders
      AllowedMethods: allowedMethods
      AllowedOrigins: allowedOrigins
      ExposeHeaders: exposedHeaders

    rule.MaxAgeSeconds = maxAge if maxAge?
    rule

  # Set Cross Origin Resource Sharing (CORS) configuration for the whole bucket.
  setCORS = async (name, config) ->
    if isArray config
      rules = (buildRule c for c in config)
    else
      rules = [buildRule config]

    try
      yield s3.putBucketCors {
        Bucket: name,
        CORSConfiguration: {
         CORSRules: rules
        },
        ContentMD5: ""
      }
    catch e
      console.error "Unexpected response while setting bucket CORS configuration.", e
      throw new Error()


  {establish, list, setACL, setCORS}
