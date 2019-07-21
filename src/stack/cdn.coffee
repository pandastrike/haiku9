import {resolve} from "path"
import {read as _read} from "panda-quill"
import {first} from "panda-parchment"
import pandaTemplate from "panda-template"
import {Helpers} from "sundog"
{fullyQualify} = Helpers.url

read = (name) ->
  _read resolve __dirname, "..", "..", "..", "..", "files", "templates", name

render = (config) ->

    fetch = (hostname) ->
      if cert = await config.sundog.ACM(region: "us-east-1").fetch hostname
        cert
      else
        throw new Error "This environment is configured to use TLS, but Haiku
          cannot locate a wildcard certificate in the us-east-1 region
          for #{hostname}"

    compileLambda = ->
      {region, environment} = config
      {hostnames} = environment

      blankBucketURL: "#{hostnames[0]}.s3-website-#{region}.amazonaws.com"

    compileCloudFront = ->
      {region, environment} = config
      {hostnames, cache} = environment
      {ssl, protocol, httpVersion, priceClass, expires, headers} = cache

      for hostname in hostnames
        hostname: hostname
        bucketURL: "#{hostname}.s3-website-#{region}.amazonaws.com"
        priceClass: priceClass ? "100"
        expires: expires ? 60
        protocolPolicy: if ssl then "redirect-to-https" else "allow-all"
        protocolVersion: protocol ? "TLSv1.2_2018"
        httpVersion: httpVersion ? "http2"
        headers: headers ? []
        certificate: if ssl then (await fetch hostname) else false

    compileRoute53 = ->
      {hostnames, hostedZoneID} = config.environment

      hostedZoneID: hostedZoneID
      record: do ->
        name: fullyQualify hostname for hostname in hostnames



    template = await read "cdn.hbs"
    T = new pandaTemplate()
    T.handlebars().registerHelper
      equal: (A, B) -> A == B

    T.render template,
      lambda: compileLambda()
      cloudfront: await compileCloudFront()
      route53: compileRoute53()

export default render
