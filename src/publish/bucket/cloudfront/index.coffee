{async, sleep} = require "fairmont"

config = require "../../../configuration"

# Handles setting up and maintaining CloudFront distributions.
module.exports = (cf) ->

    set: async ->
      if config.s3.cloudFront.ssl
        console.log "CloudFront CDN. HTTPS with redirect."
      else
        console.log "CloudFront CDN. HTTP-Only."

      yield require("./distribution")(cf)

    # Wait until we're sure everything is ready on the edge servers.  For new
    # distributions, that means waiting until we get a `Deployed` status. And
    # in every case we invalidate the cache after an update.
    sync: async (distribution, {dlist, ulist})->
      if distribution.Status != "Deployed"
        console.log "Waiting for CloudFront distribution to deploy. " +
          "This will take several minutes."

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


      invalidation = yield require("./invalidation")(cf, distribution, dlist,
        ulist)

      if invalidation && !distribution.isNew
        console.log "Invalidating cache. This will take several minutes."
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
