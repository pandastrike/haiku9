{async, collect, where, empty} = require "fairmont"
{randomKey} = require "key-forge"

config = require "../../../configuration"

# TODO add configuration for cloudfront restrictions.
module.exports = async (cf) ->

  {bucketURL, fullyQualify, regularlyQualify, root} = require "../url"

  createDistribution = async ->
    try
      {ssl, priceClass} = config.s3.cloudFront
      protocolPolicy = if ssl then "redirect-to-https" else "allow-all"
      priceClass ||= "100"
      originID = "Haiku9-" + regularlyQualify bucketURL()

      # Fill out configuration for CloudFront distribution... it's a doozy.
      params =
        DistributionConfig:
          CallerReference: "Haiku " + randomKey 32
          Comment: "Origin is S3 bucket. Setup by Haiku9."
          Enabled: true
          PriceClass: "PriceClass_" + priceClass
          DefaultRootObject: config.s3.web.index

          Aliases:
            Quantity: 1
            Items: [ config.s3.bucket ]

          Origins:
            Quantity: 1
            Items: [
              Id: originID
              DomainName: config.s3.bucket + ".s3.amazonaws.com"
              S3OriginConfig:
                OriginAccessIdentity: ""
            ]

          DefaultCacheBehavior:
            TargetOriginId: originID
            ForwardedValues:
              QueryString: false
              Cookies:
                Forward: "none"
              Headers:
                Quantity: 0
            MinTTL: 86400
            TrustedSigners:
              Enabled: false
              Quantity: 0
            ViewerProtocolPolicy: protocolPolicy
            AllowedMethods:
              Items: [ "GET", "HEAD" ]
              Quantity: 2
              CachedMethods:
                Items: [ "GET", "HEAD" ]
                Quantity: 2
            Compress: false

      if ssl
        params.ViewerCertificate =
          MinimumProtocolVersion: "TLSv1"
          SSLSupportMethod: "sni-only"
          # ACMCertificateArn: 'STRING_VALUE'
          # IAMCertificateId: 'STRING_VALUE'

      distribution = yield cf.createDistribution params
      distribution.isNew = true
      distribution
    catch e
      console.error "Unexpected response while creating CloudFront" +
        "distribution.", e
      throw new Error()



  try
    # Search the user's current distributions for one that matches this
    # request.  If we don't find one, create it.
    pattern =
      Aliases:
        Quantity: 1,
        Items: [ regularlyQualify config.s3.bucket ]

    data = yield cf.listDistributions {}
    result = collect where pattern, data.DistributionList.Items
    if empty result then yield createDistribution() else result[0]
  catch e
    console.error "Unexpected response while prepping CloudFront distro", e
    throw new Error()
