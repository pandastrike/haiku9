# We cannot use the configuration directly.  To make the code and the CLI more
# flexible, we need to construct a data object that's slightly streamlined
# from the one set by the user in h9.yaml
{collect, where, empty} = require "fairmont"

module.exports = (config, env) ->
  out = config
  {aws} = config
  out.aws = {
    region: aws.region
    site: aws.site
  }

  # Pull config data for the requested environment.
  env = collect where {title: env}, aws.environments
  if empty env
    console.error "Cannot find config for specified environment. Aborting."
    throw new Error()
  else
    env = env[0]

  # Construct an array of full subdomains to feed the process.
  names = []
  names.push (name + "." + aws.domain) for name in env.hostnames
  names.push aws.domain if env.apex
  out.aws.hostnames = names

  # Pull CloudFront (cdn / caching) info into the config
  out.aws.cache = env.cache

  # Return the compiled config.
  out
