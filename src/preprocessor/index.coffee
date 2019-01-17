import {first} from "panda-parchment"
import setCORS from "./cors"

preprocess = (config, environment) ->
  {aws, sundog} = config
  {hzGet} = sundog.Route53()

  # Pull config data for the requested environment.
  config.environment = aws.environments[environment]
  if !config.environment?
    console.error "Cannot find config for specified environment. Aborting."
    throw new Error()

  # Construct an array of full subdomains to feed the process.
  names = []
  names.push (name + "." + aws.domain) for name in env.hostnames
  names.unshift aws.domain  if env.apex == "primary"
  names.push aws.domain     if env.apex == "secondary"
  config.environment.hostnames = names

  # Confirm this account has a Route53 hosted zone for Haiku to access.
  if (zone = await hzGet first names)
    config.environment.hostedZoneID = zone.Id
  else
    throw new Error "It appears you do not have a public hostedzone setup
      for #{root first names}  Without it, H9 cannot setup the DNS
      records to route traffic to your bucket."

  # Pull CloudFront (cdn / caching) info into the config
  config.environment.cache = env.cache ? {}

  # Validate the use of wildcard in CloudFront header forwarding.
  {headers} = config.environment.cache
  if (headers?.length > 1) && ("*" in headers)
    throw new Error "Incorrect header specificaton.  Wildcard cannot be used with other named headers."

  # Validate that the CloudFront CORS configuration is consistent with S3 bucket
  setCORS config

export default preprocess
