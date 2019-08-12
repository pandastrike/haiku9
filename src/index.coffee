import "source-map-support/register"
import "colors"
import {flow} from "panda-garden"

import {logger, bell, stopwatch as Stopwatch} from "./utils"
import readConfiguration from "./configuration"
import {setupEdgeLambdas, teardownEdgeLambas} from "./lambdas"
import {setupBucket, scanBucket, syncBucket, teardownBucket} from "./bucket"
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
  setupBucket
  scanBucket
  scanLocal
  reconcile
  syncBucket
  publishStack
  end
]

teardown = flow [
  start
  readConfiguration
  teardownStack
  teardownBucket
  teardownEdgeLambas
  end
]

export {publish, teardown}
export default {publish, teardown}
