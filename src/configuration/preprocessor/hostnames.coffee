import {flow} from "panda-garden"
import {first, rest} from "panda-parchment"
import {Helpers} from "sundog"

{root, fullyQualify} = Helpers.url

setHostnames = (config) ->
  {domain, environment} = config
  {hostnames, apex} = environment

  names = []
  names.push (name + "." + domain) for name in hostnames
  names.unshift domain  if apex == "primary"
  names.push domain     if apex == "secondary"
  config.environment.hostnames = names
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
      primary:
        name: fullyQualify first hostnames
      secondaries: do ->
        name: fullyQualify hostname for hostname in rest hostnames

  config

setHostnames = flow [
  setCoreHostnames
  setHostedZone
  expandTemplateConfig
]

export default setHostnames
