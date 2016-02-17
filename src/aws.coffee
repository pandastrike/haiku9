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

liftModule = (m) ->
  out = {}
  out[k] = lift m, v for k, v of m
  out

# For now, this assumes AWS credentials are stored in a Yaml document at ~/.h9
# TODO: Is this an okay way to handle this?
awsPath = join homedir(), ".h9"

module.exports = call ->
  config = safeLoad yield read awsPath
  repoConfig = require "./configuration"
  {id, key} = config.aws
  AWS.config =
     accessKeyId: id
     secretAccessKey: key
     region: repoConfig.s3.region
     sslEnabled: true

  # Module's we'd like to invoke from AWS are listed and lifted here.
  cf = liftModule new AWS.CloudFront()
  route53 = liftModule new AWS.Route53()
  s3 = liftModule new AWS.S3()

  {cf, route53, s3}
