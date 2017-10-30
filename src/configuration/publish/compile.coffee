# We cannot use the configuration directly.  To make the code and the CLI more
# flexible, we need to construct a data object that's slightly streamlined
# from the one set by the user in h9.yaml
{collect, where, empty} = require "fairmont"

module.exports = (config, env) ->
  out = config
  {aws} = config

  # Pull config data for the requested environment.
  env = aws.environments[env]
  if !env
    console.error "Cannot find config for specified environment. Aborting."
    throw new Error()

  # Construct an array of full subdomains to feed the process.
  names = []
  names.push (name + "." + aws.domain) for name in env.hostnames
  names.unshift aws.domain  if env.apex == "primary"
  names.push aws.domain     if env.apex == "secondary"
  out.aws.hostnames = names

  # Pull CloudFront (cdn / caching) info into the config
  out.aws.cache = env.cache

  # Return the compiled config.
  out
