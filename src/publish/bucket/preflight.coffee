config = require "../../configuration"

# Makes sure that the user has valid configuration.
# TODO: As configuration gets more complex, consider using jsck instead.
module.exports = ->
  web = config.s3.web
  if !web
    console.error "Cannot find website configuration for S3."
    throw new Error()

  if !web.index
    console.error "Please name an index page for S3 bucket."
    throw new Error()

  if !web.error
    console.error "Please name an error page for S3 bucket."
    throw new Error()
