{readFileSync} = require "fs"
{join} = require "path"

JSCK = require "jsck"
{empty} = require "fairmont"
yaml = require "js-yaml"

module.exports = do ->
  try
    schema = yaml.safeLoad readFileSync join(__dirname, "schema.yaml")
    jsck = new JSCK.draft4 schema
    config = yaml.safeLoad readFileSync "h9.yaml"
    {errors} = jsck.validate config
  catch e
    console.error "There was a problem validating this repo's configuration.", e
    throw new Error()

  if !empty errors
    console.error "There is a problem with this repo's configurtion. Aborting."
    console.error errors
    throw new Error()

  # TODO: Remove this when we actually start supporting SSL.
  if config.s3.cloudFront?.ssl
    console.error "SSL setup is not currently supported. Exiting."
    process.exit()

  config
