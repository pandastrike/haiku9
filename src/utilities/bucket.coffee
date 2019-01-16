import {join} from "path"
import {first, second} from "panda-parchment"
import {partition} from "panda-river"
import ProgressBar from "progress"
import {usesDefaultExtension, stripExtension, isTooLarge} from "./helpers"

class ObjectTable
  constructor: (@table, @directories) ->

  isCurrent: (key, hash) ->
    if (remoteHash = @table[key])?
      hash == remoteHash
    else if usesDefaultExtension key
      @isCurrent stripExtension key
    else
      false

Bucket = (sundog, config) ->
  {
    bucketHead, bucketSetACL, bucketSetCORS, list,
    delBatch: _delBatch, put: _put
  } = sundog.S3()

  {source, environment} = config
  names = environment.hostnames

  # Create a new bucket or make sure an existing one is properly configured.
  _establish = ({cors}, name) ->
    await bucketTouch name
    await bucketSetACL name, "public-read"
    (await bucketSetCORS name, cors) if cors

  establish = ->
    (await _establish environment, name) for name in names

    await bucketSetWebsite (first names),
      index: config.aws.site.index.toString()
      error: config.aws.site.error.toString()

    for name in rest names
      await bucketSetWebsite (first names), false,
        host: first names
        protocol: "https"

  # Scan for S3 bucket to form an ETag dictionary, ignoring S3 directory keys.
  scan = (name) ->
    objects = await list name
    table = {}
    directories = []
    for {Key, ETag} in objects
      if Key.match /.*\/$/
        directories.push Key
      else
        table[Key] = second ETag.split "\""

    new ObjectTable table, directories

  getObjectTable = -> await scan first names


  delBatch = (batch) -> _delBatch (first names), batch
  put = (key) ->
    await _put (first names), key, join source, key
    await putACL (first names), key, "public-read"

  sync = ({deletions, uploads}) ->
      {tick} = new ProgressBar "syncing [:bar] :percent",
        total: deletions.length + uploads.length
        complete: "="
        incomplete: " "

      # process object deletion queue
      for batch in partition 1000, deletions
        await delBatch batch
        tick batch.length

      # process object upload queue
      for key in uploads
        if await isTooLarge join source, key
          tick()
          continue

        await put key
        await put stripExtension key if usesDefaultExtension key
        tick()

  {establish, getObjectTable, sync}

export default Bucket
