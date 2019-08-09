import {resolve} from "path"
import {isEmpty, include, dashed} from "panda-parchment"

setLambdas = (config) ->
  {name, env} = name
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

  for key of config.environment.edge

    include config.environment.edge[key],
      name: "haiku9-#{name}-#{env}-#{dashed key}"
      type: dashed key

    config.environment.edge[key].handler ?= "index.handler"
    config.environment.edge[key].tracingConfig ?= "PassThrough"

    if key in ["viewerRequest", "viewerResponse"]
      include config.environment.edge[key], memorySize: 128
      config.environment.edge[key].timeout ?= 5
    else
      config.environment.edge[key].memorySize ?= 128
      config.environment.edge[key].timeout ?= 30


  config.environment.edge.src = "lambdas-#{source}"
  config.environment.edge.role = "haiku9-#{name}-#{env}-edge-lambdas"
  config

export default setLambdas
