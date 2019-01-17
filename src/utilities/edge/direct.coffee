import {resolve} from "path"
import {read} from "panda-quill"
import {first} from "panda-parchment"
import pandaTemplate from "panda-template"
import {lookupS3HostedZoneID} from "./templates/s3-hostedzone-ids"

render = ({sundog, environment, aws:{region}}) ->
    {fullyQualify} = sundog.URL

    # Ready the template
    T = new pandaTemplate()
    template = await read resolve __dirname, "templates", "direct.hbs"

    # Compile the configuration needed to fill out the above template.
    {hostnames, hostedZoneID} = environment

    T.render template,
      hostedZoneID: hostedZoneID
      records: for hostname in hostnames
        name: fullyQualify hostname
        alias:
          hostname: "s3-website-#{region}.amazonaws.com."
          hostedZoneID: lookupS3HostedZoneID region

export default render
