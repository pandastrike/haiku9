{async} = require "fairmont"
config = require "../../configuration"


module.exports = (s3) ->
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
        Bucket: config.s3.bucket,
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

  {listObjects}
