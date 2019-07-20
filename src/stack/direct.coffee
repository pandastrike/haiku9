import {resolve} from "path"
import {read as _read} from "panda-quill"
import {first} from "panda-parchment"
import pandaTemplate from "panda-template"
import {lookupS3HostedZoneID} from "./s3-hostedzone-ids"
import {Helpers} from "sundog"
{fullyQualify} = Helpers.url

read = (name) ->
  _read resolve __dirname, "..", "..", "..", "files", "templates", name

render = ({sundog, environment, region}) ->
    # Ready the template
    T = new pandaTemplate()
    template = await read "direct.hbs"

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
