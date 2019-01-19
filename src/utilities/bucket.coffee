import {join} from "path"
import {first, second, rest} from "panda-parchment"
import {partition} from "panda-river"
import ProgressBar from "progress"
import {usesDefaultExtension, stripExtension, isTooLarge} from "./helpers"

class Bucket
  constructor: (@table, @directories) ->

  @create: (table, dictionaries) -> new Bucket table, dictionaries

  isCurrent: (key, hash) ->
    if (remoteHash = @table[key])?
      hash == remoteHash
    else if usesDefaultExtension key
      @isCurrent stripExtension key
    else
      false

Utility = ({sundog, source, environment, site}) ->
  s3 = sundog.S3()
  names = environment.hostnames

  # Create a new bucket or make sure an existing one is properly configured.
  _establish = ({cors}, name) ->
    await s3.bucketTouch name
    await s3.bucketSetACL name, "public-read"
    (await s3.bucketSetCORS name, cors) if cors

  establish = ->
    (await _establish environment, name) for name in names

    await s3.bucketSetWebsite (first names),
      index: site.index.toString()
      error: site.error.toString()

    for name in rest names
      await s3.bucketSetWebsite name, false,
        host: first names
        protocol: if environment.cache?.ssl then "https" else "http"

  # Scan for S3 bucket to form an ETag dictionary.
  scan = (name) ->
    objects = await s3.list name
    table = {}
    directories = []
    for {Key, ETag} in objects
      if Key.match /.*\/$/
        directories.push Key
      else
        table[Key] = second ETag.split "\""

    Bucket.create table, directories

  getObjectTable = -> await scan first names


  deleteBatch = (batch) -> s3.deleteBatch (first names), batch
  put = (key, alias) ->
    await s3.PUT.file (first names), (alias ? key), (join source, key),
      ACL: "public-read"

  _sync = (deletions, uploads, progress) ->
    # process object deletion queue
    for batch in partition 1000, deletions
      await deleteBatch batch
      progress.tick batch.length

    # process object upload queue
    for key in uploads
      if await isTooLarge join source, key
        progress.tick()
        continue

      await put key
      await put key, stripExtension key if usesDefaultExtension key
      progress.tick()

  sync = ({deletions, uploads}) ->
      total = deletions.length + uploads.length
      if total == 0
        console.error "H9: WARNING - S3 Bucket is already up-to-date.
          Nothing to sync.".yellow
      else
        progress = new ProgressBar "syncing [:bar] :percent",
          total: total
          complete: "="
          incomplete: " "

        await _sync deletions, uploads, progress

  destroy = ->
    await s3.bucketEmpty first names
    await s3.bucketDelete name for name in names

  {establish, getObjectTable, sync, delete: destroy}

export default Utility
