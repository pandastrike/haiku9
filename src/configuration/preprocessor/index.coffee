import {flow} from "panda-garden"
import {first} from "panda-parchment"
import setCORS from "./cors"
import {Helpers} from "sundog"

{root} = Helpers.url

setEnvironment = (config) ->
  config.environment = config.environments[config.env]

  unless config.environment?
    throw new Error "No configuration for '#{config.env}'"
  config

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

  unless zone = await hzGet first config.environment.names
    throw new Error "It appears you do not have a public hostedzone setup
      for #{root first config.environment.names}  Without it, H9 cannot
      setup the DNS records to route traffic to your bucket."
  else
    config.environment.hostedZoneID = zone
  config

checkCacheHeaders = (config) ->
  if {headers} = config.environment.cache?
    if (headers.length > 1) && ("*" in headers)
      throw new Error "Incorrect header specificaton.  Wildcard cannot be used with other named headers."
  config

preprocess = flow [
  setEnvironment
  setHostnames
  setHostedZone
  checkCacheHeaders
  setCORS
]

export default preprocess
