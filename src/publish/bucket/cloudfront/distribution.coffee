{async, collect, where, empty, cat, sleep} = require "fairmont"
{randomKey} = require "key-forge"

config = require "../../../configuration"

# TODO add configuration for cloudfront restrictions.
module.exports = async (cf) ->

  {bucketURL, fullyQualify, regularlyQualify, root} = require "../url"
  acm = require("./acm")((yield require("../../../aws")("us-east-1")).acm)

  # Invalidate distribution cache.  Because we are charged per path we specify,
  # it's cheapest to just invalidate everything unless nothing changed.
  invalidate = async (distribution, {dlist, ulist}) ->
    createInvalidation = async ->
      yield cf.createInvalidation
        DistributionId: distribution.Id
        InvalidationBatch:
          CallerReference: "Haiku" + randomKey 32
          Paths:
            Quantity: 1
            Items: ["/*"]

    try
      return null if empty cat dlist, ulist
      {Invalidation} = yield createInvalidation()
    catch e
      console.error "Unexpected response while setting invalidation.", e
      throw new Error()


  set = async (name) ->
    buildSource = (name) ->
      name + ".s3-website-" + config.s3.region + ".amazonaws.com"

    buildConfiguration = async (name) ->
      {ssl, priceClass} = config.s3.cloudFront
      protocolPolicy = if ssl then "redirect-to-https" else "allow-all"
      priceClass ||= "100"
      originID = "Haiku9-" + regularlyQualify name

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
            Items: [ name ]

          Origins:
            Quantity: 1
            Items: [
              Id: originID
              DomainName: buildSource name
              CustomOriginConfig:
                HTTPPort: 80
                HTTPSPort: 443
                OriginProtocolPolicy: "http-only"
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
        params.DistributionConfig.ViewerCertificate =
          MinimumProtocolVersion: "TLSv1"
          SSLSupportMethod: "sni-only"
          ACMCertificateArn: yield acm.fetch config.s3.hostnames[0]

      return params


    createDistribution = async (name) ->
      try
        params = yield buildConfiguration name
        distribution = yield cf.createDistribution params
        distribution.isNew = true
        distribution
      catch e
        console.error "Unexpected response while creating CloudFront" +
          "distribution.", e
        throw new Error()

    updateDistribution = async (name, id, tag) ->
      try
        params = {Id: id, IfMatch: tag}
        yield cf.deleteDistribution params

        params = yield buildConfiguration name
        distribution = yield cf.updateDistribution params
        distribution.isNew = true
        distribution
      catch e
        console.error "Unexpected response while updating CloudFront" +
          "distribution.", e
        throw new Error()



    try
      # Search the user's current distributions for ones that matches our needs.
      # If we don't find one, create it. If it's misconfigured, update it.
      list = (yield cf.listDistributions {}).DistributionList.Items
      ssl = config.s3.cloudFront.ssl

      pattern =
        Aliases:
          Quantity: 1,
          Items: [ regularlyQualify name ]

      matches = collect where pattern, list

      # Create a distribution for this hostname, if it doesn't exist.
      return createDistribution name if empty matches

      # If the distribution does exist, get its ID and current version ETag.
      id = matches[0].Id
      tag = (yield cf.getDistribution {Id: id}).ETag

      # Confirm that the distribution is correctly configured.
      if !ssl
        if matches[0].ViewerCertificate
          updateDistribution name, id, tag
        else
          matches[0]
      else
        pattern.ViewerCertificate =
          MinimumProtocolVersion: "TLSv1"
          SSLSupportMethod: "sni-only"
          ACMCertificateArn: yield acm.fetch config.s3.hostnames[0]

        matches = collect where pattern, list
        if empty matches
          updateDistribution name, id, tag
        else
          matches[0]

    catch e
      console.error "Unexpected response while prepping CloudFront distro", e
      throw new Error()



  sync = async (distribution) ->
    try
      retry = true
      while retry
        data = yield cf.getDistribution Id: distribution.Id
        if data.Distribution.Status == "Deployed"
          retry = false
        else
          yield sleep 15000
    catch e
      console.error "Unexpected response while checking CloudFront " +
        "distribution status."
      throw new Error()


  syncInvalidation = async (distribution, invalidation) ->
    if invalidation && !distribution.isNew
      try
        retry = true
        while retry
          data = yield cf.getInvalidation
            DistributionId: distribution.Id
            Id: invalidation.Id

          if data.Invalidation.Status == "Completed"
            retry = false
          else
            yield sleep 15000
      catch e
        console.error "Unexpected response while checking distribution " +
          "invalidation status.", e
        throw new Error()



  {invalidate, set, sync, syncInvalidation}
