import {resolve} from "path"
import {read} from "panda-quill"
import {first} from "panda-parchment"
import pandaTemplate from "panda-template"

render = ({sundog, environment, aws:{region}}) ->
    {fullyQualify} = sundog.URL
    {fetch} = sundog.ACM "us-east-1"  # Quirk of where we always put certs.

    compileCloudFront = (hostname, cache) ->
      {ssl, protocol, httpVersion, priceClass, expires, headers} = cache

      hostname: hostname
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
    template = await read resolve __dirname, "templates", "cdn.hbs"

    # Compile the configuration needed to fill out the above template.
    {hostnames, hostedZoneID, cache} = environment

    T.render template,
      endpoints: for hostname, index in hostnames
        index: index + 1
        cloudfront: compileCloudfront hostname, cache
        route53: compileRoute53 hostname, hostedZoneID

export default render
