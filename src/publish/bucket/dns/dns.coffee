# Set of helper functions and prepartion steps to setting the DNS record on
# an S3 bucket's static site or CloudFront distribution.

{async, last, first, rest, collect, where, empty,
deepEqual } = require "fairmont"

module.exports = (config, route53) ->

  {bucketURL, fullyQualify, regularlyQualify, root} = require("../url")(config)


  # Prepare a set of DNS changes that Route53 uses to present the bucket or
  # CloudFront distribution at the desired URL.  Or, if none, return null.
  build = async (distributions) ->
    changeList = []  # Ultimate goal is to fill this with actions.

    # Adds a deletion event to the DNS batch changes.
    # TODO: Make deletion more robust at deleting different kinds of records.
    addDeletion = (record, target) ->
      delete record[0].ResourceRecords if empty record[0].ResourceRecords

      Action: "DELETE",
      ResourceRecordSet: record[0]

    # Adds a creation event to the DNS batch changes.
    addCreation = (source, target) ->
      if distributions
        HostedZoneId = "Z2FDTNDATAQYW2"
      else
        HostedZoneId = require("./s3-hostedzone-ids")[config.aws.region]

      Action: "CREATE",
      ResourceRecordSet:
        Name: target
        Type: "A"
        AliasTarget:
          HostedZoneId: HostedZoneId
          DNSName: source
          EvaluateTargetHealth: false

    # Determine if the AWS user owns the requested URL as a public hosted zone
    getHostedZoneID = async ->
      zone = root config.aws.hostnames[0]
      zones = yield route53.listHostedZones {}
      result = collect where {Name: zone}, zones.HostedZones
      if empty result
        console.error("It appears you do not have a public hostedzone setup " +
          "for #{root config.aws.hostnames[0]}  Without it, H9 cannot setup the DNS " +
          "records to route traffic to your bucket.  Aborting.")
        throw new Error()

      result[0].Id

    # Scan this hosted zone and determine the changes for this particular record
    reconcile = (records, hostname, source) ->
      record = collect where {Name: hostname}, records

      if !empty record
        # Escape if there's nothing to change, else add a deletion task.
        desired = addCreation(source, hostname).ResourceRecordSet
        current = record[0]
        delete current.ResourceRecords if empty current.ResourceRecords

        return null if deepEqual desired, current
        changeList.push addDeletion record, hostname

      # Add a creation task.
      changeList.push addCreation source, hostname



    # "Main" section of build(), construct the changeList
    try
      id = yield getHostedZoneID()
      records = yield route53.listResourceRecordSets HostedZoneId: id
      records = records.ResourceRecordSets

      hostnames = []
      sources = []

      hostnames.push fullyQualify name for name in config.aws.hostnames

      if distributions
        sources.push distro.DomainName for distro in distributions
      else
        sources.push bucketURL() for i in [0...hostnames.length]

      for i in [0...hostnames.length]
        reconcile records, hostnames[i], sources[i]

      # changeList is declared above. The goal is to build a list with reconcile
      # If there are changes, return the configuration object for the AWS call.
      if empty changeList
        false
      else
        HostedZoneId: id
        ChangeBatch: Changes: changeList
    catch e
      console.error "Unexpected response while setting DNS records", e
      throw new Error()

  {build}
