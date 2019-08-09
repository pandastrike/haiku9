import {resolve} from "path"
import {flow} from "panda-garden"
import {first} from "panda-parchment"
import {read} from "panda-quill"
import pandaTemplate from "panda-template"

T = new pandaTemplate()

renderTemplate = (config) ->
  console.error "H9: rendering cloudformation template"
  process.exit()
  {templateData} = config.environment
  template = await read resolve __dirname, "..", "..", "..",
    "files", "templates", "cloudfront.hbs"

  config.environment.template = T.render template, templateData
  config

buildStack = (config) ->
  {hostnames, template} = config.environment
  # CloudFormation stack names must be [A-Za-z0-9-] and less than 128 characters
  generateStackName = (name) -> name.replace(/\./g, "-")[...128]

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
  console.error "H9: publishing cloudformation stack"
  {put} = config.sundog.CloudFormation()
  await put config.environment.stack
  config

invalidateCache = (config) ->
  console.error "H9: issuing cloudfront invalidation..."
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
  console.error "H9: issuing cloudfront teardown..."
  {delete:destroy} = config.sundog.CloudFormation()
  await destroy generateStackName first config.environment.hostnames
  config

export {publishStack, teardownStack}
