import readConfiguration from "./configuration"
import preprocessor from "./preprocessor"
import setupSDK from "./aws"
import Bucket from "./bucket"

h9Tasks = (p9k, source) ->

  {define, glob, read} = p9k

  localFiles = {}
  bucketFiles = {}

  publish = (environment) ->
    config = await readConfiguration()
    await preprocessor config, environment
    AWS = setupSDK config
    bucket = Bucket AWS

    go [
      glob "**/*", source
    ]

export default h9Tasks
