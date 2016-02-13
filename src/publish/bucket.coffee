{createReadStream} = require "fs"
{join} = require "path"
{call, async, read, last} = require "fairmont"

{target, s3} = require "../configuration"
config = s3

module.exports = call ->

  {s3} = yield require "../aws"

  # Extracts data from object header list and creates a lookup table.
  catTable = (table, data) ->
    for obj in data
      table[obj.Key] =
        hash: obj.ETag.split("\"")[1]
        size: obj.Size
    table

  # Recursive helper to grab all of the object headers in an S3 bucket
  listObjects = async (objects, marker) ->
    try
      params =
        Bucket: config.bucket,
        Delimiter: '#'
        MaxKeys: 1000

      params["Marker"] = marker if marker
      data = yield s3.listObjects params

      if data.IsTruncated
        yield listObjects (catTable objects, data.Contents), data.NextMarker
      else
        catTable objects, data.Contents
    catch e
      console.error "Unexpected reply while pulling S3 bucket keys.", e
      throw new Error()


  # Establishes what objects already exist up in S3.
  scan: async ->
    # Search your buckets to see if it exists.  If it doesn't, create it.
    try
      match = yield s3.headBucket Bucket: config.bucket
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
        yield s3.createBucket Bucket: config.bucket
        {}
      catch e
        console.error "Failed to establish bucket.", e
        throw new Error()
    else
      # We found an existing bucket.  Scan it for objects and their md5 hashes.
      yield listObjects {}


  # Uploads / Deletes S3 objects as neccessary from the target bucket.
  sync: async ({dlist, ulist}) ->
    # Delete Files
    try
      for file in dlist
        params =
          Bucket: config.bucket
          Key: file

        yield s3.deleteObject params
    catch e
      console.error "Failed to delete object.", e
      throw new Error()

    # Cleanup any S3 pseudo "directories" emptied by the deletion.
    try
      data = yield listObjects {}
      for k, v of data when k.match /.*\/$/ && v.size == 0
        params =
          Bucket: config.bucket
          Key: k

        yield s3.deleteObject params
    catch e
      console.error "Failed to delete object.", e
      throw new Error()

    # Upload Files
    try
      for file in ulist
        params =
          Bucket: config.bucket
          Key: file.split(".html")[0]   # Strip ".html" extension for S3 key. 
          Body: createReadStream join target, file

        yield s3.putObject params
    catch e
      console.error "Failed to upload object.", e
      throw new Error()
