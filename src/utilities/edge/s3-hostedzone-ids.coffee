# This hash allows us to lookup the hostezoneID of a given S3 region endpoint.
# We need this to properly setup DNS records.

# TODO: This either needs to be configurable or regularly updated to keep up with AWS.
S3HostedZones =
  "ap-northeast-1": "Z2M4EHUR26P7ZW"
  "ap-northeast-2": "Z3W03O7B5YMIYP"
  "ap-northeast-3": "Z2YQB5RD63NC85"
  "ap-south-1": "Z11RGJOFQNVJUP"
  "ap-southeast-1": "Z3O0J2DXBE1FTB"
  "ap-southeast-2": "Z1WCIGYICN2BYD"

  "ca-central-1": "Z1QDHH18159H29"

  "eu-central-1": "Z21DNDUVLTQW6Q"
  "eu-west-1": "Z1BKCTXD74EZPE"
  "eu-west-2": "Z3GKZC51ZF0DB4"
  "eu-west-3": "Z3R1K369G5AVDG"
  "eu-north-1": "Z3BAZG2TWCNX0D"

  "sa-east-1": "Z7KQH4QJS55SO"

  "us-east-1": "Z3AQBSTGFYJSTF"
  "us-east-2": "Z2O1EMRO9K5GLX"
  "us-west-1": "Z2F56UZL2M1ACD"
  "us-west-2": "Z3BJ6K6RIION7M"

lookupS3HostedZoneID = (region) ->

  if (id = S3HostedZones[region])?
    id
  else
    throw new Error "H9 does not recognize the AWS region '#{region}'
      for DNS routing.  That could just be that the region was added after
      this version of H9 was published."


export {S3HostedZones, lookupS3HostedZoneID}
