import "source-map-support/register"
import Accept from "@hapi/accept"
import {isEmpty} from "panda-parchment"
import {lookupType, isCompressible, notAcceptable} from "./utils"

handler = (event, context, callback) ->
  {request} = event.Records[0].cf

  console.log
    input:
      uri: request.uri
      accept: request.headers["accept"]?[0]?.value
      acceptEncoding: request.headers["accept-encoding"]?[0]?.value

  # Negotiate the final "Accept" Header and assign to request
  try
    header = request.headers["accept"]?[0]?.value ?  "*/*"
    allowedType = lookupType request
    acceptable = Accept.mediaType header, [ allowedType ]
    return callback null, notAcceptable allowedType if isEmpty acceptable
  catch e
    console.error e
    return callback null, notAcceptable allowedType

  request.headers["accept"] = [
    key: "Accept"
    value: acceptable
  ]


  try
    allowedTypes =
      if isCompressible allowedType
        ["br", "gzip", "identity"]
      else
        ["identity"]

    header = request.headers["accept-encoding"]?[0]?.value ? "identity"
    acceptable = Accept.encoding header, allowedTypes
    return callback null, notAcceptable allowedTypes if isEmpty acceptable
  catch e
    console.error e
    return callback null, notAcceptable allowedTypes

  request.headers["accept-encoding"] = [
    key: "Accept-Encoding"
    value: acceptable
  ]

  console.log
    output:
      uri: request.uri
      accept: request.headers["accept"][0].value
      acceptEncoding: request.headers["accept-encoding"][0].value

  callback null, request

export {handler}
