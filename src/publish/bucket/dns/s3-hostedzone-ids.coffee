# This hash allows us to lookup the hostezoneID of a given S3 region endpoint.
# We need this to properly setup DNS records.

# TODO: This is super brittle and gross. Figure out a better solution.
module.exports =
  "us-east-1": "Z3AQBSTGFYJSTF"
  "us-west-2": "Z3BJ6K6RIION7M"
  "us-west-1": "Z2F56UZL2M1ACD"
  "eu-west-1": "Z1BKCTXD74EZPE"
  "eu-central-1": "Z21DNDUVLTQW6Q"
  "ap-southeast-1": "Z3O0J2DXBE1FTB"
  "ap-northeast-1": "Z2M4EHUR26P7ZW"
  "ap-southeast-2": "Z1WCIGYICN2BYD"
  "ap-northeast-2": "Z3W03O7B5YMIYP"
  "sa-east-1": "Z7KQH4QJS55SO"
  "us-gov-west-1": "Z31GFT0UA1I2HV"
