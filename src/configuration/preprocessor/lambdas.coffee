import {flow} from "panda-garden"
import {resolve, parse} from "path"
import {resolve as resolveURL} from "url"
import {isEmpty, include, dashed, clone} from "panda-parchment"
import {read, rm, rmr, mkdir, write}, from "panda-quill"
import PandaTemplate from "panda-template"
import {shell} from "../../utils"
import {gzip, brotli} from "../../helpers"

T = new PandaTemplate()

defaultDir = resolve __dirname, "..", "..", "..", "..", "..",
  "files", "default-lambdas"

deployDir = resolve process.cwd(), "haiku9-deploy"



cleanDirectory = (config) ->
  console.log "cleaning Haiku deploy directory"
  await rmr "haiku9-deploy"
  await mkdir "0777", "haiku9-deploy"

  config

startEdgeConfig = (config) ->
  config.environment.edge ?= {}
  config.environment.edge.primary = clone config.environment.edge
  config

buildSecondaryLambda = (config) ->
  {hostnames} = config.environment

  sourceDir = resolve defaultDir, "secondary", "origin-request", "lib"
  targetDir = resolve deployDir, "secondary", "lib"
  await shell "cp -R #{sourceDir} #{targetDir}"

  path = resolve targetDir, "environment.hbs"
  template = await read path
  await rm path

  url = "https://#{hostnames[0]}"
  file = T.render template, {url}
  await write (resolve targetDir, "environment.js"), file

  console.log "compressing redirect lambda for deploy."
  await shell "zip -qr -9 origin-request.zip lib", "haiku9-deploy/secondary"
  await shell "rm -rf lib", "haiku9-deploy/secondary"

applySecondaryLambdas = (config) ->
  {hostnames} = config.environment

  if hostnames.length > 1
    console.log "loading secondary hostname redirect lambdas."
    await buildSecondaryLambda config

    config.environment.edge.secondary =
      originRequest:
        runtime: "nodejs10.x"
        src: resolve deployDir, "secondary", "origin-request.zip"
        handler: "lib/index.handler"

  config


buildPrimaryDefaultLambdas = (config) ->
  # Origin Requst Lambda
  console.log "  - Default Origin-Requst Lambda..."
  {source, index:indexKey} = config.site
  indexFile = await read (resolve source, indexKey), "buffer"
  indexFileGzip = await gzip indexFile
  indexFileBrotli = await brotli indexFile

  sourceDir = resolve defaultDir, "primary", "origin-request", "lib"
  targetDir = resolve deployDir, "primary", "lib"
  await shell "cp -R #{sourceDir} #{targetDir}"

  path = resolve targetDir, "index-files"
  await mkdir "0777", path
  await write (resolve path, "identity"), indexFile
  await write (resolve path, "gzip"), indexFileGzip
  await write (resolve path, "brotli"), indexFileBrotli

  await shell "zip -qr -9 origin-request.zip lib", "haiku9-deploy/primary"
  await shell "rm -rf lib", "haiku9-deploy/primary"


  # Origin Response Lambda
  console.log "  - Default Origin-Response Lambda..."
  {source, error:errorKey} = config.site
  errorFile = await read (resolve source, errorKey), "buffer"
  errorFileGzip = await gzip errorFile
  errorFileBrotli = await brotli errorFile

  sourceDir = resolve defaultDir, "primary", "origin-response", "lib"
  targetDir = resolve deployDir, "primary", "lib"
  await shell "cp -R #{sourceDir} #{targetDir}"

  path = resolve targetDir, "error-files"
  await mkdir "0777", path
  await write (resolve path, "identity"), errorFile
  await write (resolve path, "gzip"), errorFileGzip
  await write (resolve path, "brotli"), errorFileBrotli

  await shell "zip -qr -9 origin-response.zip lib", "haiku9-deploy/primary"
  await shell "rm -rf lib", "haiku9-deploy/primary"



applyDefaultPrimaryLambdas = (config) ->

  if isEmpty config.environment.edge.primary
    console.log "loading default static site lambdas"
    await buildDefaultPrimaryLambdas config

    config.environment.edge.primary =
      viewerRequest:
        runtime: "nodejs10.x"
        src: resolve defaultDir, "primary", "viewer-request.zip"
        handler: "lib/index.handler"
      originRequest:
        runtime: "nodejs10.x"
        src: resolve defaultDir, "primary", "viewer-request.zip"
        handler: "lib/index.handler"
        memorySize: 1600
      originResponse:
        runtime: "nodejs10.x"
        src: resolve defaultDir, "primary", "origin-response.zip"
        handler: "lib/index.handler"
        memorySize: 1600

  config

expandConfig = (config) ->
  {name, env} = config
  {hostnames, edge:{primary}} = config.environment

  for key of primary
    include primary[key],
      name: "haiku9-#{name}-#{env}-#{dashed key}"
      type: dashed key

    primary[key].src = resolve process.cwd(), primary[key].src
    primary[key].handler ?= "index.handler"
    primary[key].tracingConfig ?= "PassThrough"

    if key in ["viewerRequest", "viewerResponse"]
      include primary[key], memorySize: 128
      primary[key].timeout ?= 5
    else
      primary[key].memorySize ?= 128
      primary[key].timeout ?= 30

  config.environment.edge.primary = primary
  config.environment.edge.src = "lambdas-#{hostnames[0]}"
  config.environment.edge.role = "haiku9-#{name}-#{env}-edge-lambdas"
  config.environment.edge.originAccess = "haiku9-#{name}-#{env}"
  config

go = flow [
  cleanDirectory
  startEdgeConfig
  applySecondaryLambdas
  applyDefaultPrimaryLambdas
  expandConfig
]

export default go
