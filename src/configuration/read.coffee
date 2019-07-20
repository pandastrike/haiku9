import {resolve} from "path"
import {include} from "panda-parchment"
import {read as _read} from "panda-quill"
import {yaml} from "panda-serialize"
import AJV from "ajv"

ajv = new AJV()

read = (name) ->
  _read resolve __dirname, "..", "..", "..", "files",
    "configuration-schema", name

readConfiguration = (env, options) ->
  path = resolve process.cwd(), "h9.yaml"
  try
    config = yaml await read path
  catch e
    console.error "Error: Unable to read h9.yaml configuration at #{path}"
    throw new Error()

  schema = yaml await read "main.yaml"
  schema.definitions = yaml await read "definitions.yaml"
  unless ajv.validate schema, config
    console.error yaml ajv.errors
    throw new Error()

  include {env, options}, config

export default readConfiguration
