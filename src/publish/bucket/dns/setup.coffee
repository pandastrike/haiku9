# Set of helper functions and prepartion steps to setting the DNS record on
# an S3 bucket's static site or CloudFront distribution.

{async, last, collect, where, empty, deepEqual} = require "fairmont"

config = require "../../../configuration"
module.exports = (route53, distribution) ->

  {bucketURL, fullyQualify, regularlyQualify, root} = require "../url"

  # Route53 DNS change objects.
  # TODO: Make deletion more robust at deleting different kinds of records.
  deletion = (record, target) ->
    delete record[0].ResourceRecords if empty record[0].ResourceRecords

    Action: "DELETE",
    ResourceRecordSet: record[0]

  creation = (source, target) ->
    if distribution
      HostedZoneId = "Z2FDTNDATAQYW2"
    else
      HostedZoneId = require("./s3-hostedzone-ids")[config.s3.region]

    Action: "CREATE",
    ResourceRecordSet:
      Name: target
      Type: "A"
      AliasTarget:
        HostedZoneId: HostedZoneId
        DNSName: source
        EvaluateTargetHealth: false

  # Using the helper functions above, prepare a set of DNS changes that Route53
  # needs to execute in order to present the bucket or CloudFront distribution
  # at the desired URL. If no changes are required, return null.
  return async ->
    try
      source = if distribution then distribution.DomainName else bucketURL()
      hostname = fullyQualify config.s3.bucket
      changeList = []

      # Determine if the AWS user owns the requested URL as a public hosted zone
      zone = root config.s3.bucket
      zones = yield route53.listHostedZones {}
      result = collect where {Name: zone}, zones.HostedZones
      if empty result
        console.error("It appears you do not have a public hostedzone setup " +
          "for #{root config.s3.bucket}  Without it, H9 cannot setup the DNS " +
          "records to route traffic to your bucket.  Aborting.")
        throw new Error()

      id = result[0].Id

      # Scan this hosted zone and build the neccessary DNS changes for Route53
      data = yield route53.listResourceRecordSets HostedZoneId: id
      record = collect where {Name: hostname}, data.ResourceRecordSets

      if !empty record
        # Escape if there's nothing to change, else add a deletion task.
        desired = creation(source, hostname).ResourceRecordSet
        current = record[0]
        delete current.ResourceRecords if empty current.ResourceRecords

        return null if deepEqual desired, current
        changeList.push deletion record, hostname

      # Add a creation task.
      changeList.push creation source, hostname

      # Done.  Return the configuration object for the AWS call.
      HostedZoneId: id
      ChangeBatch: Changes: changeList
    catch e
      console.error "Unexpected response while searching DNS records", e
      throw new Error()
