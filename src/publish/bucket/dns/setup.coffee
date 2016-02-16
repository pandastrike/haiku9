# Set of helper functions and prepartion steps to setting the DNS record on
# an S3 bucket's static site.

{async, last, collect, where, empty, deepEqual} = require "fairmont"

config = require "../../../configuration"
module.exports = (route53) ->

  # Route53 DNS change objects.
  # TODO: Make deletion more robust at deleting different kinds of records.
  deletion = (record, target) ->
    delete record[0].ResourceRecords if empty record[0].ResourceRecords

    Action: "DELETE",
    ResourceRecordSet: record[0]

  creation = (bucket, target) ->
    zones = require "./s3-hostedzone-ids"

    Action: "CREATE",
    ResourceRecordSet:
      Name: target
      Type: "A"
      AliasTarget:
        HostedZoneId: zones[config.s3.region]
        DNSName: bucket
        EvaluateTargetHealth: false

  # Enforces "fully qualified" form of hostnames and domains.  Idompotent.
  fullyQualify = (name) -> if last(name) == "." then name else name + "."

  # Named somewhat sarcastically.  Enforces "regular" form of hostnames
  # and domains that is more expected when navigating.  Idompotnent.
  regularlyQualify = (name) -> if last(name) == "." then name[...-1] else name

  # Given an arbitrary URL, return the fully qualified root domain.
  # https://awesome.example.com/test/42#?=What+is+the+answer  =>  example.com.
  root = (url) ->
    try
      # Remove protocol (http, ftp, etc.), if present, and get domain
      domain = url.split('/')
      domain = if "://" in url then domain[2] else domain[0]

      # Remove port number, if present
      domain = domain.split(':')[0]

      # Now grab the root: the top-level-domain, plus the term to the left.
      terms = regularlyQualify(domain).split(".")
      terms = terms.slice(terms.length - 2)

      # Return the fully qualified version of the root
      fullyQualify terms.join(".")
    catch e
      console.error "Failed to parse root url", e
      throw new Error()

  # From the bucket name and region, we can construct the bucket's URL.
  # We construct the region-specific endpoint. AWS docs make a vague reference
  # to its ability to "reduce data latency", but it's not clear how many ms
  # we are saving in the response time.
  bucketURL = -> "s3-website-" + config.s3.region + ".amazonaws.com."


  # Using the helper functions above, prepare a set of DNS changes that Route53
  # needs to execute in order to present the bucket at the desired URL. If no
  # changes are required, return null.
  return async ->
    try
      bucket = bucketURL()
      hostname = fullyQualify config.s3.bucket
      changeList = []

      # Determine if the AWS user owns the requested URL as a public hosted zone
      zone = root config.s3.bucket
      zones = yield route53.listHostedZones {}
      result = collect where {Name: zone}, zones.HostedZones
      if empty result then return null else id = result[0].Id

      # Scan this hosted zone and build the neccessary DNS changes for Route53
      data = yield route53.listResourceRecordSets HostedZoneId: id
      record = collect where {Name: hostname}, data.ResourceRecordSets

      if !empty record
        # Escape if there's nothing to change, else add a deletion task.
        desired = creation(bucket, hostname).ResourceRecordSet
        current = record[0]
        delete current.ResourceRecords if empty current.ResourceRecords

        return null if deepEqual desired, current
        changeList.push deletion record, hostname

      # Add a creation task.
      changeList.push creation bucket, hostname

      # Done.  Return the configuration object for the AWS call.
      HostedZoneId: id
      ChangeBatch: Changes: changeList
    catch e
      console.error "Unexpected response while searching DNS records", e
