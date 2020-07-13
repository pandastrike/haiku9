import "source-map-support/register"
import "colors"
import {flow} from "panda-garden"

import {logger, bell, stopwatch as Stopwatch} from "./utils"
import readConfiguration from "./configuration"
import {setupEdgeLambdas, teardownEdgeLambdas} from "./lambdas"
import {syncBucket, teardownBucket} from "./bucket"
import {scanLocal, reconcile} from "./local"
import {publishStack, teardownStack} from "./stack"

logger()

start = (env, options) ->
  stopwatch = Stopwatch()
  {env, options, stopwatch}

end = (config) ->
  console.log config.stopwatch()
  console.log bell

publish = flow [
  start
  readConfiguration
  setupEdgeLambdas
  syncBucket
  publishStack
  end
]

teardown = flow [
  start
  readConfiguration
  teardownStack
  teardownBucket
  teardownEdgeLambdas
  end
]

export {publish, teardown}
export default {publish, teardown}
