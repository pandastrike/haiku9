import {resolve} from "path"

paths =
  br: do (path=undefined) ->
    path = resolve __dirname, "index-files", "brotli"
    body: (await read path, "buffer").toString "base64"
    bodyEncoding: "base64"
  gzip: do (path=undefined) ->
    path = resolve __dirname, "index-files", "gzip"
    body: (await read path, "buffer").toString "base64"
    bodyEncoding: "base64"
  identity: do (path=undefined) ->
    path = resolve __dirname, "index-files", "identity"
    body: (await read path, "buffer").toString "utf8"
    bodyEncoding: "text"

response = (request) ->

  encoding = request.headers["accept-encoding"][0].value
  {body, bodyEncoding} = await paths[encoding]

  status: "200",
  statusDescription: "200 OK"
  body: body
  bodyEncoding: bodyEncoding
  headers:
    "access-control-allow-origin": [
      key: "Access-Control-Allow-Origin"
      value: "*"
    ]
    "content-type": [
        key: "Content-Type",
        value: "text/html"
    ]
    "content-encoding": [
        key: "Content-Encoding",
        value: encoding
    ]

export default response
