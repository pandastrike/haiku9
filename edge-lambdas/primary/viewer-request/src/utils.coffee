import {toJSON} from "panda-parchment"
import mime from "mime"

lookupType = (request) ->
  if (type = mime.getType request.uri)?
    type
  else
    "text/html"

isCompressible = (accept) ->
  return true if (/^application\/json$/.test accept) ||
    (/^application\/javascript$/.test accept) ||
    (/^text\//.test accept) ||
    (/^image\/svg/.test accept)

  false

notAcceptable = (value) ->
  status: "406",
  statusDescription: "406 Not Acceptable"
  body: toJSON error: "Supported values: #{value}"
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

export {lookupType, isCompressible, notAcceptable}
