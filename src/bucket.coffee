import {relative, join} from "path"
import mime from "mime"
import ProgressBar from "progress"
import {flow} from "panda-garden"
import {first, second, rest, cat, include, toJSON} from "panda-parchment"
import {read} from "panda-quill"
import {partition} from "panda-river"
import {md5, strip, tripleJoin, isTooLarge, gzip, brotli, isCompressible} from "./helpers"

establishBucket = (config) ->
  console.log "establishing bucket..."
  s3 = config.sundog.S3()
  {hostnames, cors} = config.environment

  await s3.bucketTouch first hostnames
  await s3.bucketSetCORS (first hostnames), cors if cors

  config

addOriginAccess = (config) ->
  s3 = config.sundog.S3()
  {get, create} = config.sundog.CloudFront().originAccess

  name = config.environment.edge.originAccess
  unless (OAID = await get name)
    OAID = (await create name).CloudFrontOriginAccessIdentity

  include config.environment.templateData.cloudfront.primary,
    originAccessID: OAID.Id


  name = config.environment.hostnames[0]
  await s3.bucketSetPolicy name, toJSON
    Version: "2008-10-17"
    Statement: [
      Effect: "Allow"
      Principal:
        CanonicalUser: OAID.S3CanonicalUserId
      Action: "s3:GetObject"
      Resource: "arn:aws:s3:::#{name}/*"
    ]

  config

setupBucket = flow [
  establishBucket
  addOriginAccess
]





emptyBucket = (config) ->
  console.log "emptying buckets"
  s3 = config.sundog.S3()
  bucket = config.environment.hostnames[0]
  await s3.bucketEmpty bucket if await s3.bucketHead bucket
  config

_teardownBucket = (config) ->
  console.log "bucket teardown"
  s3 = config.sundog.S3()
  bucket = config.environment.hostnames[0]
  await s3.bucketDelete bucket
  config

teardownAccessOriginID = (config) ->
  console.log "origin access ID teardown"
  {delete: teardown} = config.sundog.CloudFront().originAccess
  await teardown config.environment.edge.originAccess
  config

teardownBucket = flow [
  emptyBucket
  _teardownBucket
  teardownAccessOriginID
]




scanBucket = (config) ->
  console.log "scanning remote files"
  bucket = first config.environment.hostnames
  {list} = config.sundog.S3()
  config.remote = hashes: {}, directories: []

  for {Key, ETag} in await list bucket, "identity"
    key = (rest (Key.split "identity/")).join "identity/"

    if Key.match /.*\/$/
      config.remote.directories.push key
    else
      config.remote.hashes[key] = second ETag.split "\""

  config

setupProgressBar = (config) ->
  {deletions, uploads} = config.tasks

  total = deletions.length + uploads.length
  if total == 0
    console.warn "S3 Bucket is already up-to-date."
  else
    config.tasks.deletionProgress = new ProgressBar "deleting [:bar] :percent",
      total: deletions.length
      width: 40
      complete: "="
      incomplete: " "

    config.tasks.uploadProgress = new ProgressBar "uploading [:bar] :percent",
      total: uploads.length
      width: 40
      complete: "="
      incomplete: " "

  config

processDeletions = (config) ->
  if config.tasks.deletions.length > 0
    console.log "deleting old files"
    {rmBatch} = config.sundog.S3()
    bucket = config.environment.hostnames[0]

    for batch from partition 1000, config.tasks.deletions
      await rmBatch bucket, batch
      config.tasks.deletionProgress.tick batch.length

  config

_put = (config) ->
  upload = config.sundog.S3().PUT.buffer
  bucket = config.environment.hostnames[0]

  (key, alias) ->
    path = join config.source, key
    file = await read path, "buffer"

    identityKey = join "identity", (alias ? key)
    gzipKey = join "gzip", (alias ? key)
    brotliKey = join "brotli", (alias ? key)

    ContentMD5 = md5 file, "base64"
    unless ContentType = mime.getType path
      throw new Error "unknown file type at #{path}"

    await Promise.all [
      upload bucket, identityKey, file,
        {ContentType, ContentMD5, ContentEncoding: "identity"}

      do ->
        if isCompressible file, ContentType
          buffer = await gzip file
          encoding = "gzip"
          hash = md5 buffer, "base64"
        else
          buffer = file
          encoding = "identity"
          hash = ContentMD5

        upload bucket, gzipKey, buffer,
          {ContentType, ContentMD5: hash, ContentEncoding: encoding}

      do ->
        if isCompressible file, ContentType
          buffer = await brotli file
          encoding = "br"
          hash = md5 buffer, "base64"
        else
          buffer = file
          encoding = "identity"
          hash = ContentMD5

        upload bucket, brotliKey, buffer,
          {ContentType, ContentMD5: hash, ContentEncoding: encoding}
    ]

processUploads = (config) ->
  if config.tasks.uploads.length > 0
    console.log "upserting files"
    put = _put config

    for key in config.tasks.uploads
      if await isTooLarge join config.source, key
        config.tasks.progress.tick()
        continue

      await put key
      await put key, strip key
      config.tasks.uploadProgress.tick()

  config

_syncBucket = flow [
  setupBucket
  scanBucket
  scanLocal
  reconcile
  setupProgressBar
  processDeletions
  processUploads
]

syncBucket = (config) ->
  if config.source?
    _syncBucket config
  else
    config

export {syncBucket, teardownBucket}
