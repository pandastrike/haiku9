import {resolve} from "path"
import {flow} from "panda-garden"
import {first} from "panda-parchment"
import {read} from "panda-quill"
import pandaTemplate from "panda-template"

T = new pandaTemplate()

generateStackName = (config) -> "haiku9-#{config.name}-#{config.env}"

renderTemplate = (config) ->
  console.log "rendering cloudformation template"

  {templateData} = config.environment
  template = await read resolve __dirname, "..", "..", "..",
    "files", "templates", "cloudfront.hbs"

  config.environment.template = T.render template, templateData
  config

buildStack = (config) ->
  {hostnames, template} = config.environment

  config.environment.stack =
    StackName: generateStackName config
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
  console.log "publishing cloudformation stack"
  {get, put, delete:_delete} = config.sundog.CloudFormation()
  {stack} = config.environment

  if (result = await get stack.StackName)
    if result.StackStatus in ["ROLLBACK_COMPLETE", "ROLLBACK_FAILED"]
      console.warn "removing inert stack #{stack.StackName}"
      await _delete stack.StackName
      console.log "continuing with deploy"

  await put stack
  config

invalidateCache = (config) ->
  console.log "issuing cloudfront invalidation..."
  {get, invalidate} = config.sundog.CloudFront()
  await invalidate await get first config.environment.hostnames
  config

publishStack = flow [
  renderTemplate
  buildStack
  deployStack
  invalidateCache
]

teardownStack = (config) ->
  console.log "issuing cloudfront teardown..."
  {delete:destroy} = config.sundog.CloudFormation()
  await destroy generateStackName config
  config

export {publishStack, teardownStack}
