import "source-map-support/register"
import errorResponse from "./error-response"

handler = (event, context, callback) ->
  try
    {request, response} = event.Records[0].cf

    if response.status == 404
      return callback null, await errorResponse request

    callback null, response

  catch e
    console.log e
    callback null, response

export {handler}
