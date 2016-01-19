# H9 uses the AWS-SDK and your credentials to directly interact with Amazon.
{join} = require "path"
{homedir} = require "os"

AWS = require "aws-sdk"
{safeLoad} = require "js-yaml"
wlift = (require "when/node").lift

{call, read, isFunction} = require "fairmont"
{task} = require "panda-9000"

# aws-sdk is a little odd.  We must instantiate a given service's sub-library
# before we may access its methods.  But, once it's done, we can go
# through the sub-module and use when.js to "lift" each method.
lift = (object, k) ->
  if isFunction k then wlift k.bind object else k

lift_module = (m) ->
  out = {}
  out[k] = lift m, v for k, v of m
  out

# For now, this assumes AWS credentials are stored in a Yaml document at ~/.h9
# TODO: Is this an okay way to handle this?
aws_path = join homedir(), ".h9"

module.exports = call ->
  config = safeLoad yield read aws_path
  {id, key, region} = config.aws
  AWS.config =
     accessKeyId: id
     secretAccessKey: key
     region: region
     sslEnabled: true

  # Module's we'd like to invoke from AWS are listed and lifted here.
  route53 = lift_module new AWS.Route53()
  s3 = lift_module new AWS.S3()

  {route53, s3}
