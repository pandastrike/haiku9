import setCORS from "./cors"

preprocess = (config, environment) ->
  {aws} = config

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

  # Pull CloudFront (cdn / caching) info into the config
  config.environment.cache = env.cache ? {}

  # Validate that the CloudFront CORS configuration is consistent with S3 bucket
  setCORS config

export default preprocess
