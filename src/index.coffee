import readConfiguration from "./configuration"
import preprocessor from "./preprocessor"
import Utilities from "./utilities"

h9Tasks = (p9k) ->

  publish = (environment) ->
    config = preprocessor (await readConfiguration()), environment
    utilities = Utilities config
    {environment} = config

    console.log "H9: Configuring S3 bucket(s)..."
    await utilities.bucket.establish()

    console.log "H9: Scanning Local Directory and S3..."
    [local, remote] = await Promise.all [
      utilities.local.getFileTable()
      utilities.bucket.getObjectTable()
    ]

    console.log "H9: Syncing S3 bucket..."
    actions = await utilities.local.reconcile local, remote
    await utilities.remote.sync actions

    if config.aws.cache
      console.log "H9: Configuring CloudFront CDN..."
      cdn = await utilities.cdn.set()

    console.log "H9: Configuring Route53 DNS..."
    await utilities.dns.set cdn

    console.log "H9: Done"

  {publish}

export default h9Tasks
