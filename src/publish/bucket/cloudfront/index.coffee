{async, sleep, isArray} = require "fairmont"

# Handles setting up and maintaining CloudFront distributions.
module.exports = async (config, cf) ->

    cf = yield require("./distribution")(config, cf)

    # Locate a CloudFront distribution that matches our needs or create it.
    set: async ->
      if config.aws.cache.ssl
        console.log "===== Using CloudFront CDN. HTTPS with redirect."
      else
        console.log "===== Using CloudFront CDN. HTTP-Only."

      yield cf.set name for name in config.aws.hostnames


    # Wait until we're sure everything is ready on the edge servers.  For new
    # distributions, that means waiting until we get a `Deployed` status. And
    # we also need to issue cache invalidations if there are content updates.
    sync: async (distributions, changes)->
      pluralString = if distributions.length > 1 then "s are " else " is "
      console.log """

        ======
        Confirming CloudFront distribution#{pluralString}synchronized.
        """

      yield cf.sync distro for distro in distributions
      console.log "CloudFront distribution synchronization#{pluralString} complete."

      if config.aws.cache.expires != 0 && cf.needsInvalidation changes
        console.log "Invalidating CDN cache. This may take several minutes."
        invalidations = []
        for distro in distributions
          invalidations.push yield cf.invalidate distro
        for i in [0...distributions.length]
          yield cf.syncInvalidation distributions[i], invalidations[i]
      console.log "CDN cache validation check complete."
