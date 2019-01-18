# This encompasses the CloudFront CDN (optional) and the Route53 deployments,
# packaged within a CloudFormation template.
import {first} from "panda-parchment"
import renderS3SiteTemplate from "./direct"
import renderCDNTemplate from "./cdn"
import {generateStackName} from "../helpers"

Utility = (config) ->
  {sundog, environment} = config
  {cache, hostnames} = environment

  if cache?.ssl
    message = "  - Configuration: CloudFront CDN. HTTPS with redirect."
  else if cache?
    message = "  - Configuration: CloudFront CDN. HTTP-Only."
  else
    message = "  - Configuration: Direct S3 Serving.  HTTP-Only."

  publishStack = (stack) ->
    {get, create, update} = sundog.CloudFormation()
    if (await get stack.StackName)
      try
        await update stack
      catch e
        if e.name == "ValidationError" &&
           e.message == "No updates are to be performed."
          console.error "H9: WARNING - No updates required to edge infrastructure. Skipping.".yellow
        else
          throw e
    else
      await create stack

  buildStack = ->
    template =
      if cache?
        await renderCDNTemplate config
      else
        await renderS3SiteTemplate config

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

  invalidateCache = ->
    console.error "H9: Issuing CloudFront invalidation..."
    {get, invalidate} = sundog.CloudFront()
    await invalidate await get first hostnames

  deploy = ->
    console.error message
    console.error "  - Please wait..."
    await publishStack await buildStack()

    await invalidateCache() if cache?


  {deploy}

export default Utility
