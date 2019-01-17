import {resolve} from "path"
import {read} from "panda-quill"
import {yaml} from "panda-serialize"
import AJV from "ajv"

ajv = new AJV()

readSchema = (name) ->
  read resolve __dirname, "..", "..", "..", ".." "configuration-schema", name

readConfiguration = ->
  path = resolve process.cwd(), "h9.yaml"
  try
    config = yaml await read path
  catch e
    console.error "Error: Unable to read h9.yaml configuration at #{path}"
    throw new Error()

  schema = yaml await readSchema "main.yaml"
  schema.definitions = yaml await readSchema "definitions.yaml"
  isValid = ajv.validate schema, config
  if !isValid
    console.error yaml ajv.errors
    throw new Error()

  config

export default readConfiguration
