import {relative, join} from "path"
import mime from "mime"
import {flow} from "panda-garden"
import {first, second, rest, partition} from "panda-parchment"
import {read, stat} from "panda-quill"
import {strip, tripleJoin, isTooLarge, gzip, brotli} from "./helpers"

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

emptyBucket = (config) ->
  S3 = config.sundog.S3()
  bucket = first config.environment.hostnames
  await s3.bucketEmpty bucket if await s3.bucketHead bucket
  config

teardownBucket = (config) ->
  S3 = config.sundog.S3()
  names = config.environment.hostnames
  await s3.bucketDelete name for name in names
  config

scanBucket = (config) ->
  bucket = first config.environment.hostnames
  {list} = config.sundog.S3()
  config.remote = hashes: {}, directories: []

  for {Key, ETag} in await list bucket, "identity"
    if Key.match /.*\/$/
      config.remote.directories.push relative "identity", Key
    else
      config.remote.hashes[Key] = second ETag.split "\""

  config

setupProgressBar = (config) ->
  {deletions, uploads} = config.tasks

  total = deletions.length + uploads.length
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

  config

_put = (config) ->
  upload = config.sundog.S3().PUT.buffer
  bucket = first config.environment.hostnames

  (key, alias) ->
    path = join config.source, key
    ContentType = mime.getType path
    file = await read path, "buffer"
    ContentMD5 = md5 file
    keys = tripleJoin (alias ? key)

    await Promise.all [
      upload bucket, keys[0], file,
        {ACL: "public-read", ContentType, ContentMD5}
      upload bucket, keys[1], (await gzip file),
        {ACL: "public-read", ContentType, ContentMD5}
      upload bucket, keys[2], (await brotli file),
        {ACL: "public-read", ContentType, ContentMD5}
    ]

processUploads = (config) ->
  put = _put first config.environment.hostnames

  for key in uploads
    if await isTooLarge join source, key
      progress.tick()
      continue

    await put key
    await put key, strip key
    config.tasks.progress.tick()

  config

syncBucket = flow [
  setupProgressBar
  processDeletions
  processUploads
]

export {setupBucket, scanBucket, syncBucket, emptyBucket, teardownBucket}
