# This encompasses the CloudFront CDN (optional) and the Route53 deployments,
# packaged within a CloudFormation template.
import renderS3SiteTemplate from "./direct"
import renderCDNTemplate from "./cdn"

Utility = (config) ->
  {sundog, environment} = config
  {cache, hostnames} = environment
  {get, create, update} = sundog.CloudFormation()

  if cache?.ssl
    message = "  - Configuration: CloudFront CDN. HTTPS with redirect."
  else if cache?
    message = "  - Configuration: CloudFront CDN. HTTP-Only."
  else
    message = "  - Configuration: Direct S3 Serving.  HTTP-Only."

  deploy = ->
    console.error message
    if cache?
      await renderCDNTemplate config
    else
      await renderS3SiteTemplate config

    # CloudFormation stack names must be [0-9a-zA-z-], start with a letter,
    # and be 128 characters or less.
    name = environment.hostnames[0].replace("/\./g", "-")[...128]

    stack =
      StackName: name
      Capabilities: ["CAPABILITY_IAM"]
      Tags:
        - Key: "deployed by"
          Value: "Haiku9"
        - Key: "domain"
          Value: environment.hostnames[0]
      TemplateBody: template

    if (await get name)
      await update stack
    else
      await create stack


  {deploy}

export default Utility
