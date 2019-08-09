import {flow} from "panda-garden"
import {first} from "panda-parchment"
import {Helpers} from "sundog"

{root, fullyQualify} = Helpers.url

setCoreHostnames = (config) ->
  {domain, environment} = config
  {hostnames, apex} = environment

  names = []
  names.push (name + "." + domain) for name in hostnames
  names.unshift domain  if apex == "primary"
  names.push domain     if apex == "secondary"
  config.environment.hostnames = names
  config

setTypedHostnames = (config) ->
  source = config.environment.hostnames[0]
  config.environment.typedHostnames = [
    "identity-#{source}",
    "gzip-#{source}",
    "brotli-#{source}"
  ]

  config

setHostedZone = (config) ->
  {hzGet} = config.sundog.Route53()

  unless zone = await hzGet first config.environment.hostnames
    throw new Error "It appears you do not have a public hostedzone setup
      for #{root first config.environment.hostnames}  Without it, H9 cannot
      setup the DNS records to route traffic to your bucket."
  else
    config.environment.hostedZoneID = zone
  config

expandTemplateConfig = (config) ->
  {hostnames, hostedZoneID} = config.environment

  config.environment.templateData =
    route53:
      hostedZoneID: hostedZoneID
      record: do ->
        name: fullyQualify hostname for hostname in hostnames

  config

setHostnames = flow [
  setCoreHostnames
  setTypedHostnames
  setHostedZone
  expandTemplate
]

export default setHostnames
