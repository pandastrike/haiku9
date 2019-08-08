import {relative, join} from "path"
import mime from "mime"
import ProgressBar from "progress"
import {flow} from "panda-garden"
import {first, second, rest, cat, toJSON} from "panda-parchment"
import {read} from "panda-quill"
import {partition} from "panda-river"
import {md5, strip, tripleJoin, isTooLarge, gzip, brotli, isCompressible} from "./helpers"

establishBuckets = (config) ->
  console.log "H9: establishing buckets..."
  s3 = config.sundog.S3()
  {hostnames, typedHostnames, cors} = config.environment

  for name in cat typedHostnames, rest hostnames
    await s3.bucketTouch name
    await s3.bucketSetACL name, "public-read"
    await s3.bucketSetCORS name, cors if cors

  config

configureBucketSources = (config) ->
  console.log "H9: setting up S3 static serving"
  s3 = config.sundog.S3()
  names = config.environment.typedHostnames

  site =
    index: config.site.index.toString()
    error: config.site.error.toString()

  await s3.bucketSetWebsite name, site for name in names
  config

configureBucketRedirects = (config) ->
  console.log "H9: setting up S3 redirects"
  s3 = config.sundog.S3()
  {hostnames:names, cache} = config.environment

  for name in rest names
    await s3.bucketSetWebsite name, false,
      host: first names
      protocol: if cache?.ssl then "https" else "http"

  config

setupBucket = flow [
  establishBuckets
  configureBucketSources
  configureBucketRedirects
]

emptyBucket = (config) ->
  console.log "H9: emptying buckets"
  s3 = config.sundog.S3()
  for bucket in config.environment.typedHostnames
    await s3.bucketEmpty bucket if await s3.bucketHead bucket
  config

teardownBucket = (config) ->
  console.log "H9: bucket teardown"
  s3 = config.sundog.S3()
  {typedHostnames: source, hostnames} = config.environment
  await s3.bucketDelete name for name in cat source, rest hostnames
  config

scanBucket = (config) ->
  console.log "H9: scanning remote files"
  bucket = first config.environment.typedHostnames
  {list} = config.sundog.S3()
  config.remote = hashes: {}, directories: []

  for {Key, ETag} in await list bucket
    if Key.match /.*\/$/
      config.remote.directories.push Key
    else
      config.remote.hashes[Key] = second ETag.split "\""

  config

setupProgressBar = (config) ->
  {deletions, uploads} = config.tasks
  console.log toJSON {deletions, uploads}, true

  total = deletions.length + uploads.length
  if total == 0
    console.error "H9: WARNING - S3 Bucket is already up-to-date.
      Nothing to sync.".yellow
  else
    config.tasks.deletionProgress = new ProgressBar "syncing [:bar] :percent",
      total: deletions.length
      width: 40
      complete: "="
      incomplete: " "

    config.tasks.uploadProgress = new ProgressBar "syncing [:bar] :percent",
      total: uploads.length
      width: 40
      complete: "="
      incomplete: " "

  config

processDeletions = (config) ->
  console.log "H9: deleting old files"
  {rmBatch} = config.sundog.S3()
  {typedHostnames:names} = config.environment

  for batch from partition 1000, config.tasks.deletions
    await rmBatch names[0], batch
    await rmBatch names[1], batch
    await rmBatch names[2], batch
    config.tasks.deletionProgress.tick batch.length

  config

_put = (config) ->
  upload = config.sundog.S3().PUT.buffer
  identityBucket = config.environment.typedHostnames[0]
  gzipBucket = config.environment.typedHostnames[1]
  brotliBucket = config.environment.typedHostnames[2]

  (key, alias) ->
    path = join config.source, key
    file = await read path, "buffer"

    ACL = "public-read"
    ContentMD5 = md5 file, "base64"
    unless ContentType = mime.getType path
      throw new Error "unknown file type at #{path}"

    await Promise.all [
      upload identityBucket, (alias ? key), file,
        {ACL, ContentType, ContentMD5, ContentEncoding: "identity"}

      do ->
        if isCompressible file, ContentType
          buffer = await gzip file
          encoding = "gzip"
          hash = md5 buffer, "base64"
        else
          buffer = file
          encoding = "identity"
          hash = ContentMD5

        upload gzipBucket, (alias ? key), buffer,
          {ACL, ContentType, ContentMD5: hash, ContentEncoding: encoding}

      do ->
        if isCompressible file, ContentType
          buffer = await brotli file
          encoding = "br"
          hash = md5 buffer, "base64"
        else
          buffer = file
          encoding = "identity"
          hash = ContentMD5

        upload brotliBucket, (alias ? key), buffer,
          {ACL, ContentType, ContentMD5: hash, ContentEncoding: encoding}
    ]

processUploads = (config) ->
  console.log "H9: upserting files"
  put = _put config

  for key in config.tasks.uploads
    if await isTooLarge join config.source, key
      config.tasks.progress.tick()
      continue

    await put key
    await put key, strip key
    config.tasks.uploadProgress.tick()

  config

syncBucket = flow [
  setupProgressBar
  processDeletions
  processUploads
]

export {setupBucket, scanBucket, syncBucket, emptyBucket, teardownBucket}
