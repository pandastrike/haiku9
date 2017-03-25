readline = require "readline"
rl = readline.createInterface
  input: process.stdin
  output: process.stdout

{createReadStream} = require "fs"
{join} = require "path"

{async, cat, stat} = require "fairmont"
mime = require "mime"

# Uploads / Deletes S3 objects as neccessary from the target bucket.
module.exports = (config, s3) ->
  bucket = require("./s3")(s3)

  async ({dlist, ulist}) ->
    console.log "Syncing S3 bucket."
    total = (cat dlist, ulist).length

    if total == 0
      rl.close()
      console.log "  ***Warning: S3 Bucket is up-to-date.  Nothing to sync."
    currentIndex = 0

    printProgress = ->
      progress = 100 * currentIndex / total
      if progress < 1
        progress = progress.toPrecision(2)
      else if progress < 10
        progress = progress.toPrecision(3)
      else
        progress = progress.toPrecision(4)

      rl.write null, {ctrl: true, name: 'u'}
      rl.write progress + "%"
      currentIndex++
      if currentIndex == total
        rl.write null, {ctrl: true, name: 'u'}
        rl.write "100%"
        rl.write "\n"
        rl.close()

    # Helper to screen out files larger than 5 GB. They cannot be stored in a
    # single S3 object, which interferes with our static-site ability.
    isTooLarge = async (path) ->
      {size} = yield stat path
      if size > 4999999999
        console.warn "The file #{path} is larger than 5GB and is too large to
        store within a single S3 object.  Haiku9 currently does not support
        multi-object files, so it is skipping this file during the sync."
        true
      else
        false

    # Delete Files
    try
      for file in dlist
        params =
          Bucket: config.aws.hostnames[0]
          Key: file

        yield s3.deleteObject params
        printProgress()

    catch e
      console.error "Failed to delete object.", e
      throw new Error()

    # Cleanup any S3 pseudo "directories" emptied by the deletion.
    try
      data = yield bucket.list config.aws.hostnames[0], {}
      for k, v of data when k.match /.*\/$/ && v.size == 0
        params =
          Bucket: config.aws.hostnames[0]
          Key: k

        yield s3.deleteObject params
    catch e
      console.error "Failed to delete object.", e
      throw new Error()

    # Upload Files
    try
      for {file, hash} in ulist
        continue if yield isTooLarge join(config.target, file)

        params =
          Bucket: config.aws.hostnames[0]
          Key: file
          ACL: "public-read"
          ContentType: mime.lookup file
          ContentMD5: new Buffer(hash, "hex").toString('base64')
          Body: createReadStream join config.target, file

        yield s3.putObject params

        if file.indexOf(".html") > -1
          # For HTML files, also publish a copy that lacks the file extension.
          params =
            Bucket: config.aws.hostnames[0]
            Key: file.split(".html")[0]
            ACL: "public-read"
            ContentType: mime.lookup file
            ContentMD5: new Buffer(hash, "hex").toString('base64')
            Body: createReadStream join config.target, file

          yield s3.putObject params

        printProgress()
    catch e
      console.error "Failed to upload object.", e
      throw new Error()
