{async, sleep, isArray} = require "fairmont"

# Handles setting up and maintaining CloudFront distributions.
module.exports = async (config, cf) ->

    cf = yield require("./distribution")(config, cf)

    # Locate a CloudFront distribution that matches our needs or create it.
    set: async ->
      if config.aws.cache.ssl
        console.log "CloudFront CDN. HTTPS with redirect."
      else
        console.log "CloudFront CDN. HTTP-Only."

      yield cf.set name for name in config.aws.hostnames


    # Wait until we're sure everything is ready on the edge servers.  For new
    # distributions, that means waiting until we get a `Deployed` status. And
    # in every case we invalidate the cache after an update.
    sync: async (distributions, changes)->
      console.log "Waiting for CloudFront distribution to deploy. " +
        "This will take 15-30 minutes."

      yield cf.sync distro for distro in distributions

      console.log "Invalidating cache. This may take several minutes."
      invalidations = []
      for distro in distributions
        invalidations.push yield cf.invalidate distro, changes
      for i in [0...distributions.length]
        yield cf.syncInvalidation distributions[i], invalidations[i]
