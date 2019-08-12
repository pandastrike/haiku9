import "source-map-support/register"
import {resolve} from "url"
import environment from "./environment"

handler = (event, context, callback) ->
  {request} = event.Records[0].cf

  primaryURL = resolve environment.url, request.uri

  callback null,
    status: "301",
    statusDescription: "301 Moved Permanently"
    body: JSON.stringify error: "301 Moved Permanently"
    bodyEncoding: "text"
    headers:
      "access-control-allow-origin": [
        key: "Access-Control-Allow-Origin"
        value: "*"
      ]
      "content-type": [
          key: "Content-Type"
          value: "application/json"
      ]
      "location": [
          key: "Location"
          value: primaryURL
      ]


  callback null, request

export {handler}
