import {flow} from  "panda-garden"
import {first, include} from "panda-parchment"

import setCORS from "./cors"

setTLSCert = (config) ->
  hostname = first config.environment.hostnames

  if (cert = await config.sundog.ACM(region: "us-east-1").fetch hostname)
    config.environment.cache.cert = cert
  else
    throw new Error "This environment is configured to use TLS, but Haiku
      cannot locate a wildcard certificate in the us-east-1 region
      for #{hostname}"

  config

checkCacheHeaders = (config) ->
  if (headers = config.environment.cache?.headers)?
    if (headers.length > 1) && ("*" in headers)
      throw new Error "Incorrect header specificaton.  Wildcard cannot be used with other named headers."
  else
    config.environment.cache.headers = [
      "Accept",
      "Accept-Encoding",
      "Access-Control-Request-Headers",
      "Access-Control-Request-Method",
      "Authorization"
    ]

  config

expandTemplateConfig = (config) ->
  {region} = config
  {hostnames, cache} = config.environment
  {priceClass, expires, cert, protocol, httpVersion, headers} = cache

  include config.environment.templateData,
    cloudfront: do ->
      for hostname, index in hostnames
        hostname: hostname
        bucketURL: do ->
          if index == 0
            "identity-#{hostname}.s3-website-#{region}.amazonaws.com"
          else
            "#{hostname}.s3-website-#{region}.amazonaws.com"
        priceClass: priceClass ? "100"
        expires: expires ? 60
        protocolPolicy: if cert then "redirect-to-https" else "allow-all"
        protocolVersion: protocol ? "TLSv1.2_2018"
        httpVersion: httpVersion ? "http2"
        headers: headers ? []
        certificate: if cert? then cert else false

  config

setCache = flow [
  setTLSCert
  checkCacheHeaders
  setCORS
  expandTemplateConfig
]

export default setCache
