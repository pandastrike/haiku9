import {first} from "panda-parchment"
import setCORS from "./cors"
import {Helpers} from "sundog"

preprocess = (config, environment) ->
  {environments, domain, sundog} = config
  {hzGet} = sundog.Route53()
  {root} = Helpers.url

  # Pull config data for the requested environment.
  config.environment = environments[environment]
  if !config.environment?
    throw new Error "Cannot find configuration for the specified environment, '#{environment}'"


  {hostnames, apex, cache} = config.environment

  # Construct an array of full subdomains to feed the process.
  names = []
  names.push (name + "." + domain) for name in hostnames
  names.unshift domain  if apex == "primary"
  names.push domain     if apex == "secondary"
  config.environment.hostnames = names

  # Confirm this account has a Route53 hosted zone for Haiku to access.
  if (zone = await hzGet first names)
    config.environment.hostedZoneID = zone
  else
    throw new Error "It appears you do not have a public hostedzone setup
      for #{root first names}  Without it, H9 cannot setup the DNS
      records to route traffic to your bucket."

  # CloudFront-specific configuration
  if cache?
    # Validate the use of wildcard in CloudFront header forwarding.
    {headers} = cache
    if (headers?.length > 1) && ("*" in headers)
      throw new Error "Incorrect header specificaton.  Wildcard cannot be used with other named headers."

    # Validate that the CloudFront CORS configuration is consistent with S3 bucket
    setCORS config

export default preprocess
