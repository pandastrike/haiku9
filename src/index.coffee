import "colors"
import readConfiguration from "./configuration"
import setupSDK from "./aws"
import preprocess from "./preprocessor"
import Utilities from "./utilities"

publish = (environment) ->
  config = await readConfiguration()
  await setupSDK config
  await preprocess config, environment
  utilities = await Utilities config
  {environment} = config

  console.error "H9: Checking S3 bucket configuration..."
  await utilities.bucket.establish()

  console.error "H9: Scanning local Files and S3..."
  [local, bucket] = await Promise.all [
    utilities.local.getFileTable()
    utilities.bucket.getObjectTable()
  ]

  console.error "H9: Syncing S3 bucket..."
  actions = await utilities.local.reconcile local, bucket
  await utilities.bucket.sync actions

  console.error "H9: Publishing edge infrastructure..."
  await utilities.edge.deploy()

  console.error "H9: Done"


export {publish}
export default {publish}
