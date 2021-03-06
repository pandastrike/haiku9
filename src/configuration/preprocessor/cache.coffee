import {flow} from  "panda-garden"
import {first, include, rest} from "panda-parchment"

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
  {priceClass, cert, protocol, httpVersion, headers, expires} = cache

  include config.environment.templateData,
    cloudfront:
      primary: do ->
        hostname = first hostnames

        hostname: hostname
        bucketURL: hostname + ".s3.amazonaws.com"
        expires: expires ? 86400
        priceClass: priceClass ? "100"
        protocolVersion: protocol ? "TLSv1.2_2018"
        httpVersion: httpVersion ? "http2"
        headers: headers ? []
        certificate: cert

      secondaries: do ->
        for hostname, index in rest hostnames
          hostname: hostname
          bucketURL: hostname + ".s3.amazonaws.com"
          priceClass: priceClass ? "100"
          protocolVersion: protocol ? "TLSv1.2_2018"
          httpVersion: httpVersion ? "http2"
          certificate: cert


  config

setCache = flow [
  setTLSCert
  checkCacheHeaders
  setCORS
  expandTemplateConfig
]

export default setCache
