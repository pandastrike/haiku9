import {resolve} from "path"
import {read as _read} from "panda-quill"
import {first} from "panda-parchment"
import pandaTemplate from "panda-template"
import {Helpers} from "sundog"
{fullyQualify} = Helpers.url

read = (name) ->
  _read resolve __dirname, "..", "..", "..", "files", "templates", name

render = ({sundog, environment, region}) ->    
    {fetch: _fetch} = sundog.ACM region: "us-east-1"

    fetch = (hostname) ->
      if cert = await _fetch hostname
        cert
      else
        throw new Error "This environment is configured to use TLS, but Haiku
          cannot locate a wildcard certificate in the us-east-1 region
          for #{hostname}"

    compileCloudFront = (hostname, cache) ->
      {ssl, protocol, httpVersion, priceClass, expires, headers} = cache

      hostname: hostname
      bucketURL: "#{hostname}.s3-website-#{region}.amazonaws.com"
      priceClass: priceClass ? "100"
      expires: expires ? 60
      protocolPolicy: if ssl then "redirect-to-https" else "allow-all"
      protocolVersion: protocol ? "TLSv1.2_2018"
      httpVersion: httpVersion ? "http2"
      headers: headers ? []
      certificate: if ssl then (await fetch hostname) else false

    compileRoute53 = (hostname, hostedZoneID) ->
      hostedZoneID: hostedZoneID
      record:
        name: fullyQualify hostname

    # Ready the template
    T = new pandaTemplate()
    template = await read "cdn.hbs"

    # Compile the configuration needed to fill out the above template.
    {hostnames, hostedZoneID, cache} = environment

    T.render template,
      endpoints: for hostname, index in hostnames
        index: index + 1
        cloudfront: await compileCloudFront hostname, cache
        route53: compileRoute53 hostname, hostedZoneID

export default render
