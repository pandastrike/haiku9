# H9 uses the AWS-SDK and your credentials to directly interact with Amazon.
{join} = require "path"
{homedir} = require "os"

AWS = require "aws-sdk"
wlift = (require "when/node").lift

{async, read, isFunction, where} = require "fairmont"
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

parseCreds = (data) ->
  lines = data.split "\n"
  get = (line) -> line.split(/\s*=\s*/)[1]
  where = (phrase) ->
    for i in [0...lines.length]
      return i if lines[i].indexOf(phrase) >= 0

  id: get lines[where "aws_access_key_id"]
  key: get lines[where "aws_secret_access_key"]

# Looks for AWS credentials stored at ~/.aws/credentials
awsPath = join homedir(), ".aws", "credentials"



module.exports = async (region) ->
  {id, key} = parseCreds yield read awsPath
  repoConfig = require "./configuration"
  AWS.config =
     accessKeyId: id
     secretAccessKey: key
     region: region || repoConfig.aws.region
     sslEnabled: true

  # Module's we'd like to invoke from AWS are listed and lifted here.
  acm = liftModule new AWS.ACM()
  cf = liftModule new AWS.CloudFront()
  route53 = liftModule new AWS.Route53()
  s3 = liftModule new AWS.S3()

  {acm, cf, route53, s3}
