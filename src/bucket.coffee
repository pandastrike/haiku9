import {sleep} from "panda-parchment"

Bucket = (sundog) ->
  {bucketHead, bucketSetACL, bucketSetCORS, list} = sundog.S3()

  # Create a new bucket or make sure an existing one is properly configured.
  establish = (name, cors) ->
    await bucketTouch name
    await bucketSetACL name, "public-read"
    (await bucketSetCORS name, cors) if cors

  # Scan for every object and form a dictionary with their ETags.
  getObjectTable = (name) ->
    objects = await list name
    table = {}
    for {Key, ETag, Size} in objects
      table[Key] =
        hash: ETag.split("\"")[1]
        size: Size
    table

  {establish, getObjectTable}

export {Bucket}
