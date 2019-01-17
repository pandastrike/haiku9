import readConfiguration from "./configuration"
import setupSDK from "./aws"
import preprocess from "./preprocessor"
import Utilities from "./utilities"

h9Tasks = (p9k) ->

  publish = (environment) ->
    config = await readConfiguration()
    await setupSDK config
    await preprocess config, environment
    utilities = await Utilities config
    {environment} = config

    console.error "H9: Configuring S3 bucket(s)..."
    await utilities.bucket.establish()

    console.error "H9: Scanning Local Directory and S3..."
    [local, remote] = await Promise.all [
      utilities.local.getFileTable()
      utilities.bucket.getObjectTable()
    ]

    console.error "H9: Syncing S3 bucket..."
    actions = await utilities.local.reconcile local, remote
    isNoOp = await utilities.remote.sync actions

    if isNoOp
      console.error "H9: WARNING - S3 Bucket is up-to-date.  Nothing to sync."
    else
      console.error "H9: Publishing edge infrastructure..."
      await utilities.edge.deploy()

    console.error "H9: Done"

  {publish}

export default h9Tasks
