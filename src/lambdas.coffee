import ProgressBar from "progress"
import {flow} from "panda-garden"
import {dashed, merge, second, toJSON, sleep} from "panda-parchment"
import {read} from "panda-quill"
import {partition} from "panda-river"
import {md5, lambdaSizeCheck} from "./helpers"

AssumeRolePolicyDocument = toJSON
  Version: "2012-10-17"
  Statement: [
    Sid: "AllowLambdaServiceToAssumeRole"
    Effect: "Allow"
    Action: [ "sts:AssumeRole" ]
    Principal:
      Service: [
        "lambda.amazonaws.com"
        "edgelambda.amazonaws.com"
      ]
  ]

policyARN = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

setEdgeLambdas = (config) ->
  if config.environment.edge

    {region, environment} = config
    {hostnames} = environment

    blankBucketURL: "#{hostnames[0]}.s3-website-#{region}.amazonaws.com"
    environment: config.env

setOrchestrationBucket = (config) ->
  console.log "setting up Edge Lambda orchestration bucket."
  s3 = config.sundog.S3()
  {src} = config.environment.edge

  await s3.bucketTouch src
  config

scanRemote = (config) ->
  console.log "scanning remote Edge Lambda code."
  bucket = config.environment.edge.src
  {list} = config.sundog.S3()
  config.remote = hashes: {}, directories: []

  for {Key, ETag} in await list bucket
    config.remote.hashes[Key] = second ETag.split "\""

  config

scanLocal = (config) ->
  console.log "scanning local Edge Lambda code"
  config.local = lambdas: {}

  for name, lambda of config.environment.edge.triggers
    config.local.lambdas["#{dashed name}.zip"] = lambda
    config.local.lambdas["#{dashed name}.zip"].hash =
      md5 (await read lambda.src, "buffer"), "hex"

  config

reconcileCode = (config) ->
  {local, remote} = config
  config.tasks = deletions: [], uploads: []

  isFilePresent = (key) -> local.lambdas[key]?
  isCurrent = (key, hash) ->
    if (remoteHash = remote.hashes[key])?
      hash == remoteHash
    else
      false

  for key of remote.hashes when !(isFilePresent key)
    config.tasks.deletions.push key

  for key, lambda of local.lambdas when !(isCurrent key, lambda.hash)
    config.tasks.uploads.push {key, lambda}

  config


setupProgressBar = (config) ->
  {deletions, uploads} = config.tasks

  total = deletions.length + uploads.length
  if total == 0
    console.warn "Lambda code is up-to-date."
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
    console.log "deleting defunct lambda code"
    {rmBatch} = config.sundog.S3()
    bucket = config.environment.edge.src

    for batch from partition 1000, config.tasks.deletions
      await rmBatch bucket, batch
      config.tasks.deletionProgress.tick batch.length

  config

processUploads = (config) ->
  if config.tasks.uploads.length > 0
    console.log "upserting lambda code"
    bucket = config.environment.edge.src
    upload = config.sundog.S3().PUT.file

    for {key, lambda} in config.tasks.uploads
      await lambdaSizeCheck lambda.src
      await upload bucket, key, lambda.src
      config.tasks.uploadProgress.tick()

  config

setupRole = (config) ->
  {role} = config.sundog.IAM()
  RoleName = config.environment.edge.role

  if (_role = await role.get config.environment.edge.role)
    ARN = _role.Role.Arn
  else
    _role = await role.create {RoleName, AssumeRolePolicyDocument}
    ARN = _role.Role.Arn
    await role.attachPolicy RoleName, policyARN

  config.environment.edge.roleARN = _role.Role.Arn
  config

publishLambdas = (config) ->
  {region, env, environment} = config
  {edge, hostnames} = environment
  bucket = edge.src

  {get, listVersions, create, update, updateConfig,
    publish} = config.sundog.Lambda()


  for {key, lambda} in config.tasks.uploads

    params =
      FunctionName: lambda.name
      Handler: lambda.handler
      Runtime: lambda.runtime
      MemorySize: lambda.memorySize
      Timeout: lambda.timeout
      TracingConfig: Mode: lambda.tracingConfig
      Role: edge.roleARN
      Environment:
        Variables: {}

    if await get lambda.name
      console.log "updating lambda #{lambda.name}"
      await update lambda.name, bucket, key
      await updateConfig null, params
    else
      console.log "creating lambda #{lambda.name}"
      await create merge params,
        Code:
          S3Bucket: bucket
          S3Key: key

    console.log "publishing lambda #{lambda.name}"
    await publish lambda.name

  for key, {name} of config.environment.edge.triggers
    versions = await listVersions name
    versions.sort (a, b) -> b.Version - a.Version
    config.environment.edge.triggers[key].arn = versions[1].FunctionArn

  config

addToCacheTemplate = (config) ->
  config.environment.templateData.cloudfront[0].lambdas = []

  for key, {type, arn} of config.environment.edge.triggers
    config.environment.templateData.cloudfront[0].lambdas.push {type, arn}

  config

teardownOrchestrationBucket = (config) ->
  console.log "tearing down edge lambda orchestration bucket"
  {bucketEmpty, bucketDelete} = config.sundog.S3()
  bucket = config.environment.edge.src
  await bucketEmpty bucket
  await bucketDelete bucket
  config

teardownRole = (config) ->
  console.log "tearing down edge lambda IAM role"
  {role} = config.sundog.IAM()

  await role.delete config.environment.edge.role
  config

syncCode = flow [
  setupProgressBar
  processDeletions
  processUploads
  setupRole
  publishLambdas
  addToCacheTemplate
]

setupEdgeLambdas = flow [
  setOrchestrationBucket
  scanRemote
  scanLocal
  reconcileCode
  syncCode
]

teardownEdgeLambdas = flow [
  (config) ->
    console.warn "Cannot delete lambdas or published versions due to replcations. Please delete in Console in a couple hours"
    config
  teardownRole
  teardownOrchestrationBucket
]


export {setupEdgeLambdas, teardownEdgeLambdas}
