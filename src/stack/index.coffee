import {flow} from "panda-garden"
import renderDirect from "./direct"
import renderCDN from "./cdn"
import {generateStackName} from "./helpers"

announce = (config) ->
  {cache} = config.environment
  if cache?.ssl
    console.log "  - Configuration: CloudFront CDN. HTTPS with redirect."
  else if cache?
    console.log "  - Configuration: CloudFront CDN. HTTP-Only."
  else
    console.log "  - Configuration: Direct S3 Serving.  HTTP-Only."
  console.error "  - Please wait..."

  config

renderTemplate = (config) ->
  config.environment.template =
    if cache?
      await renderCDN config
    else
      await renderDirect config
  config

buildStack = (config) ->
  {hostnames, template} = config.environment

  config.environment.stack =
    StackName: generateStackName first hostnames
    Capabilities: ["CAPABILITY_IAM"]
    Tags: [{
      Key: "deployed by"
      Value: "Haiku9"
    }, {
      Key: "domain"
      Value: first hostnames
    }]
    TemplateBody: template

  config

deployStack = (config) ->
  {put} = config.sundog.CloudFormation()
  await put config.environment.stack
  config

invalidateCache = (config) ->
  console.error "H9: Issuing CloudFront invalidation..."
  {get, invalidate} = config.sundog.CloudFront()
  await invalidate await get first config.environment.hostnames
  config

publishStack = flow [
  announce
  renderTemplate
  buildStack
  deployStack
  invalidateCache
]

teardownStack = (config) ->
  {delete:destroy} = config.sundog.CloudFormation()
  await destroy generateStackName first config.environment.hostnames
  config

export {publishStack, teardownStack}
