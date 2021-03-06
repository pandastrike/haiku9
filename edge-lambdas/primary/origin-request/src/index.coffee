import "source-map-support/register"
import {join} from "path"
import indexResponse from "./index-response"

handler = (event, context, callback) ->
  try
    {request} = event.Records[0].cf

    console.log
      uri: request.uri
      accept: request.headers["accept"][0].value
      acceptEncoding: request.headers["accept-encoding"][0].value

    if request.uri == "/"
      return callback null, await indexResponse request

    switch request.headers["accept-encoding"][0].value
      when "br"
        request.uri = join "/brotli", request.uri
      when "gzip"
        request.uri = join "/gzip", request.uri
      when "identity"
        request.uri = join "/identity", request.uri

    callback null, request

  catch e
    console.log e
    request.uri = join "/identity", request.uri
    callback null, request

export {handler}
