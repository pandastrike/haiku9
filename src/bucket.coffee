import {flow} from "panda-garden"
import {first, second, rest, partition} from "panda-parchment"

setupBucket = (config) ->
  s3 = config.sundog.S3()
  {hostnames:names, cors} = config.environment.hostnames

  for name in names
    await s3.bucketTouch name
    await s3.bucketSetACL name, "public-read"
    await s3.bucketSetCORS name, cors if cors

  site =
    index: config.site.index.toString()
    error: config.site.error.toString()
  redirect =
    host: first names
    protocol: if config.environment.cache?.ssl then "https" else "http"

  await s3.bucketSetWebsite (first names), site
  await s3.bucketSetWebsite name, false, redirect for name in rest names

  config

scanBucket = (config) ->
  {list} = config.sundog.S3()
  config.remote = hashes: {}, directories: []

  for {Key, ETag} in await list first config.environment.hostnames
    if Key.match /.*\/$/
      config.remote.directories.push Key
    else
      config.remote.hashes[Key] = second ETag.split "\""

  config

setupProgressBar = (config) ->
  {deletions, uploads} = config.tasks

  total = (deletions.length * 3) + (uploads.length * 3)
  if total == 0
    console.error "H9: WARNING - S3 Bucket is already up-to-date.
      Nothing to sync.".yellow
  else
    config.tasks.progress = new ProgressBar "syncing [:bar] :percent",
      total: total
      complete: "="
      incomplete: " "

  config

processDeletions = (config) ->
  for batch in partition 1000, config.tasks.deletions
    await deleteBatch batch
    progress.tick batch.length

syncBucket = flow [
  setupProgressBar
  processDeletions
  processUploads
]




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



export {setupBucket, scanBucket, syncBucket, emptyBucket, teardownBucket}
