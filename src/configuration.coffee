import {resolve} from "path"
import {read} from "panda-quill"
import YAML from "js-yaml"
import AJV from "ajv"

ajv = new AJV()

readSchema = (name) ->
  read resolve __dirname, "..", "..", "..", ".." "configuration-schema", name

readConfiguration = ->
  config = YAML.safeLoad await read resolve process.cwd(), "h9.yaml"

  schema = YAML.safeLoad await readSchema "main.yaml"
  schema.definitions = YAML.safeLoad await readSchema "definitions.yaml"
  isValid = ajv.validate schema, config
  if !isValid
    console.error JSON.stringify ajv.errors
    throw new Error()

  config

export default readConfiguration
