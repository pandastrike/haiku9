# If we make it to this file, the user has a S3 CORS configuration, but has
# not set an explicit CF headers policy, so we need to fill in the gaps with
# smart defaults and a warning if we need to.

# ** NOTE: the default CORS flag is specified in the schema but enforced here.

# Case 1)
# =========================
# If the S3 CORS configuration is permissive, it will be tempting to not set
# the CloudFront Header Caching field.  If there is something in the headers
# field, don't do anything because we assume user knows what they are doing.
# But otherwise, we need to whitelist a permissive set of headers.

# Case 2)
# ========================
# If there is an S3 CORS configuration, but it is not set to the permissive
# catch-all, we need to warn the user that the default CloudFront
# Header behavior does not cache anything.

import {isString} from "panda-parchment"

printWarning = ->
  msg = """"
  ==============================================================
  WARNING: There is a specific S3 CORS configuration, but the corresponding
  CloudFormation configuration does not include an explicit header caching
  policy.

  By default, CloudFront doesn't consider headers when caching your objects in
  edge locations. If your origin returns two objects and they differ only by the
  values in the request headers, CloudFront caches only one version of the object.

  If this is intentional, you can hide this warning by setting, within your
  environment, cache.headers to []
  ==============================================================
  """
  console.warn msg

permissiveHeaders = [
  "Accept",
  "Accept-Charset",
  "Accept-Datetime",
  "Accept-Language",
  "Access-Control-Request-Headers",
  "Access-Control-Request-Method",
  "Authorization",
  "Host",
  "Origin",
  "Referer"
]

defaultFlags = [ "default", "permissive", "wildstyle", "fuck-it", "fuck-this-thing-in-particular" ]


# Validates that the CloudFront CORS configuration is consistent with S3 bucket
setCORS = (config) ->
  {cors, cache} = config.environment
  if cors?
    if (isString cors) && (cors in defaultFlags)
      config.environment.cache.headers = permissiveHeaders
    else if !cache.headers?
      # There is an S3 CORS settting, and it's explict / detailed,
      # CF headers have undefined configuration. Warn the dev.
      printWarning()

export default setCORS
