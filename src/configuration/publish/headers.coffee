# If we make it to this file, the user has a S3 CORS configuration, but has
# not set an explicit CF headers policy, so we need to fill in the gaps with
# smart defaults and a warning if we need to.

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

permissiveHeaders = [
  "Accept",
  "Accept-Charset",
  "Accept-Datetime",
  "Accept-Language",
  "Access-Control-Request-Headers",
  "Access-Control-Request-Method",
  "Authorization",
  "CloudFront-Forwarded-Proto",
  "CloudFront-Is-Desktop-Viewer",
  "CloudFront-Is-Mobile-Viewer",
  "CloudFront-Is-SmartTV-Viewer",
  "CloudFront-Is-Tablet-Viewer",
  "CloudFront-Viewer-Country",
  "Host",
  "Origin",
  "Referer"
]

printWarning = ->
  msg = """"
  ==============================================================
  WARNING: There is an S3 CORS configuration, but the corresponding
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

module.exports = (out, defs) ->
  {aws} = out
  if aws.cors && typeof aws.cors == "string" && aws.cors in defs.corsRuleDefault.enum
    out.aws.cache.headers = permissiveHeaders
  else if aws.cors
    printWarning()
  out
