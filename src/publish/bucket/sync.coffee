{createReadStream} = require "fs"
{join} = require "path"

{async} = require "fairmont"
mime = require "mime"

config = require "../../configuration"

# Uploads / Deletes S3 objects as neccessary from the target bucket.
module.exports = (s3) ->
  {listObjects} = require("./helpers")(s3)

  async ({dlist, ulist}) ->
    console.log "Syncing S3 bucket."
    # Delete Files
    try
      for file in dlist
        params =
          Bucket: config.s3.bucket
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
          Bucket: config.s3.bucket
          Key: k

        yield s3.deleteObject params
    catch e
      console.error "Failed to delete object.", e
      throw new Error()

    # Upload Files
    try
      for file in ulist
        params =
          Bucket: config.s3.bucket
          Key: file.split(".html")[0]   # Strip ".html" extension for S3 key.
          ACL: "public-read"
          ContentType: mime.lookup file
          Body: createReadStream join config.target, file

        yield s3.putObject params
    catch e
      console.error "Failed to upload object.", e
      throw new Error()
