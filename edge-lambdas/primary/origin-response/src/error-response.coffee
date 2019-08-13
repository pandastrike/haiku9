import {resolve} from "path"
import {read} from "panda-quill"

paths =
  br: do (path=undefined) ->
    path = resolve __dirname, "error-files", "brotli"
    body: (await read path, "buffer").toString "base64"
    bodyEncoding: "base64"
  gzip: do (path=undefined) ->
    path = resolve __dirname, "error-files", "gzip"
    body: (await read path, "buffer").toString "base64"
    bodyEncoding: "base64"
  identity: do (path=undefined) ->
    path = resolve __dirname, "error-files", "identity"
    body: (await read path, "buffer").toString "utf8"
    bodyEncoding: "text"

response = (request, response) ->

  encoding = request.headers["accept-encoding"][0].value
  {body, bodyEncoding} = await paths[encoding]

  response.status = "200"
  response.statusDescription = "200 OK"
  response.body = body
  response.bodyEncoding = bodyEncoding

  response.headers["access-control-allow-origin"] = [
    key: "Access-Control-Allow-Origin"
    value: "*"
  ]

  response.headers["content-type"] = [
    key: "Content-Type"
    value: "text/html"
  ]

  response.headers["content-encoding"] = [
    key: "Content-Encoding"
    value: encoding
  ]

  response.headers["vary"] = [
    key: "Vary"
    value: "Accept-Encoding"
  ]

  response

export default response
