import "source-map-support/register"
import errorResponse from "./error-response"

handler = (event, context, callback) ->
  try
    {request, response} = event.Records[0].cf

    data =
      uri: request.uri
      accept: request.headers["accept"][0].value
      acceptEncoding: request.headers["accept-encoding"][0].value
      status: response.status

    console.log data

    if data.status > 399
      if data.accept == "text/html"
        callback null, await errorResponse request, response
      else
        response.status = "404"
        response.statusDescription = "404 Not Found"
        response.body = JSON.stringify error: "Not Found"
        callback null, response
    else
      callback null, response

  catch e
    console.log e
    callback null, response

export {handler}
