import {resolve} from "path"
import {isEmpty, include, dashed, clone} from "panda-parchment"

setLambdas = (config) ->
  {name, env} = config
  source = config.environment.hostnames[0]
  {edge} = config.environment
  edge ?= {}

  if isEmpty edge
    config.environment.edge =
      viewerRequest:
        runtime: "nodejs10.x"
        src: resolve __dirname, "..", "..", "..", "..", "..",
        "files", "default-lambdas", "viewer-request.zip"
        handler: "lib/index.handler"

  # Nest this for later processing.
  edge = triggers: clone config.environment.edge

  for key of edge.triggers
    include edge.triggers[key],
      name: "haiku9-#{name}-#{env}-#{dashed key}"
      type: dashed key

    edge.triggers[key].src = resolve process.cwd(), edge.triggers[key].src
    edge.triggers[key].handler ?= "index.handler"
    edge.triggers[key].tracingConfig ?= "PassThrough"

    if key in ["viewerRequest", "viewerResponse"]
      include edge.triggers[key], memorySize: 128
      edge.triggers[key].timeout ?= 5
    else
      edge.triggers[key].memorySize ?= 128
      edge.triggers[key].timeout ?= 30

  config.environment.edge = edge
  config.environment.edge.src = "lambdas-#{source}"
  config.environment.edge.role = "haiku9-#{name}-#{env}-edge-lambdas"
  config

export default setLambdas
