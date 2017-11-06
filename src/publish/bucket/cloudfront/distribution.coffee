{async, sleep,
collect, where, empty, cat,
clone, deepEqual} = require "fairmont"
{randomKey} = require "key-forge"

# TODO add configuration for cloudfront restrictions.
module.exports = async (config, cf) ->

  {bucketURL, fullyQualify, regularlyQualify, root} = require("../url")(config)
  acm = require("./acm")(
    config,
    (yield require("../../../aws")("us-east-1")).acm
  )

  needsInvalidation = ({dlist, ulist}) -> !empty cat dlist, ulist

  # Invalidate distribution cache.  Because we are charged per path we specify,
  # it's cheapest to just invalidate everything unless nothing changed.
  invalidate = async (distribution) ->
    createInvalidation = async ->
      yield cf.createInvalidation
        DistributionId: distribution.Id
        InvalidationBatch:
          CallerReference: "Haiku" + randomKey 32
          Paths:
            Quantity: 1
            Items: ["/*"]

    try
      {Invalidation} = yield createInvalidation()
    catch e
      console.error "Unexpected response while setting invalidation.", e
      throw new Error()


  set = async (name) ->
    buildSource = (name) -> name + ".s3.amazonaws.com"

    setViewerCertificate = async ->
      {ssl, protocol} = config.aws.cache
      if ssl
        cert = yield acm.fetch config.aws.hostnames[0]

        ACMCertificateArn: cert
        SSLSupportMethod: 'sni-only'
        MinimumProtocolVersion: protocol || 'TLSv1.2_2018'
        Certificate: cert
        CertificateSource: 'acm'
      else
        CloudFrontDefaultCertificate: true
        MinimumProtocolVersion: 'SSLv3'
        CertificateSource: 'cloudfront'

    setHeaderCacheConfiguration = ->
      {headers} = config.aws.cache

      if !headers || headers.length == 0
        # The field is unspecifed or declared explicitly to include no headers,
        # so we need to return 0 quantity.  Default forwarding with no caching.
        {Quantity: 0, Items: []}
      else if "*" in headers
        # Wildcard specificaton.  Everything gets forwarded with no caching.
        if headers.length == 1
          {Quantity: 1, Items: ["*"]}
        else
          throw new Error "Incorrect header specificaton.  Wildcard cannot be used with other named headers."
      else
        # Named, finite headers specified.  These get forwarded AND cached by CloudFront.
        {Quantity: headers.length, Items: headers}

    buildOrigins = (name, originID) ->
      Quantity: 1
      Items: [
        Id: originID
        DomainName: buildSource name
        CustomHeaders:
          Quantity: 0
          Items: []
        OriginPath: ""
        S3OriginConfig:
          OriginAccessIdentity: ""
      ]


    # This method takes into consideration the input configuration and sets smart defaults for CloudFront configuration
    # to fill the gaps where the user has no opinon set.
    applyDefaults = async (name) ->
      {ssl, priceClass, httpVersion} = config.aws.cache

      protocolPolicy: if ssl then "redirect-to-https" else "allow-all"
      priceClass: priceClass || "100"
      originID: "Haiku9-" + regularlyQualify name
      cert: yield setViewerCertificate()
      headers: setHeaderCacheConfiguration()
      expires: config.aws.cache.expires || 60
      httpVersion: httpVersion || "http2"

    # This helper constructs a CloudFront distribution configuration.  It optionally
    # accepts a pre-existing configuration to faciliate a deepEqual comparison for
    # update detection.
    buildConfiguration = async (name, c={}) ->
      distro = yield applyDefaults name

      # Fill out configuration for CloudFront distribution... it's a doozy.
      c.CallerReference = c.CallerReference || "Haiku " + randomKey 32
      c.Comment = "Origin is S3 bucket. Setup by Haiku9."
      c.Enabled = true
      c.PriceClass = "PriceClass_" + distro.priceClass
      c.ViewerCertificate = distro.cert
      c.HttpVersion = distro.httpVersion
      c.DefaultRootObject = ""

      c.Aliases =
        Quantity: 1
        Items: [ name ]

      c.Origins = c.Origins || buildOrigins(name, distro.originID)

      c.DefaultCacheBehavior =
        TargetOriginId: distro.originID
        SmoothStreaming: false
        MinTTL: 0
        MaxTTL: distro.expires
        DefaultTTL: distro.expires
        ViewerProtocolPolicy: distro.protocolPolicy
        Compress: false
        ForwardedValues:
          Cookies:
            Forward: "all"
          Headers: setHeaderCacheConfiguration()
          QueryString: true
          QueryStringCacheKeys:
            Quantity: 1
            Items: ["*"]
        TrustedSigners:
          Enabled: false
          Quantity: 0
          Items: []
        AllowedMethods:
          Items: [ "GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE" ]
          Quantity: 7
          CachedMethods:
            Items: [ "GET", "HEAD", "OPTIONS" ]
            Quantity: 3
        LambdaFunctionAssociations:
          Quantity: 0
          Items: []


      return c



    createDistribution = async (name) ->
      console.log "-- Creating CloudFront CDN Distribution for #{name}"
      try
        params = DistributionConfig: yield buildConfiguration name
        distribution = yield cf.createDistribution params
        distribution.isNew = true
        distribution
      catch e
        console.error "Unexpected response while creating CloudFront" +
          "distribution.", e
        throw new Error()

    updateDistribution = async (ETag, Distribution) ->
      console.log "-- Updating CloudFront CDN Distribution for #{name}"
      try
        params =
          Id: Distribution.Id
          IfMatch: ETag
          DistributionConfig: Distribution.DistributionConfig

        yield cf.updateDistribution params
      catch e
        console.error "Unexpected response while updating CloudFront" +
          "distribution.", e
        throw new Error()


    # This recursive helper smooths out arrays within nested objects so that we
    # can safely apply a deepEqual to compare current and new configurations.
    deepSort = (o) ->
      if Array.isArray o
        o.sort()
      else if typeof o == "object"
        n = {}
        n[k] = deepSort v for k,v of o
        n
      else
        o

    # Compare the current configuration we fetched from AWS to our desired end
    # state.  Because the configuration is complex and filled with optional fields,
    # we designate the desired configuration as a transformation on the current.
    # If this causes changes, then we need to issue a time consuming update.
    confirmDistributionConfig = async (name, {ETag, Distribution}) ->
      current = deepSort Distribution.DistributionConfig
      newconfig = deepSort yield buildConfiguration name, Object.assign({}, current)

      if deepEqual current, newconfig
        Distribution
      else
        updateDistribution ETag, Distribution






    try
      # Search the user's current distributions for ones that matches our needs.
      # If we don't find one, create it. If it's misconfigured, update it.
      list = (yield cf.listDistributions {}).DistributionList.Items

      pattern =
        Aliases:
          Quantity: 1,
          Items: [ regularlyQualify name ]

      matches = collect where pattern, list

      # Create a distribution for this hostname, if it doesn't exist.
      return createDistribution name if empty matches

      # If the distribution does exist, get its ID and current version ETag.
      match = matches[0]
      id = match.Id
      current = yield cf.getDistribution {Id: id}

      # Confirm that the distribution is correctly configured. Return it
      # if true, update it if false and return the new object
      yield confirmDistributionConfig name, current

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



  {needsInvalidation, invalidate, set, sync, syncInvalidation}
