import "source-map-support/register"
import "colors"
import {flow} from "panda-garden"
import readConfiguration from "./configuration"
import {setupBucket, scanBucket, syncBucket, emptyBucket, teardownBucket} from "./bucket"
import {scanLocal, reconcile} from "./local"
import {publishStack, teardownStack} from "./stack"

publish = flow [
  readConfiguration
  setupBucket
  scanBucket
  scanLocal
  reconcile
  syncBucket
  publishStack
]

teardown = flow [
  readConfiguration
  teardownStack
  emptyBucket
  teardownBucket
]

export {publish, teardown}
export default {publish, teardown}
