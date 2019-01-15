{async, sleep} = require "fairmont"

config = require "../../../configuration"

# Handles setting up DNS records to assign the desired hostname to the bucket.
module.exports = (config, route53) ->

  dns = require("./dns")(config, route53)

  set: async (distributions) ->
    console.log "\n====="
    console.log "-- Establishing DNS record for site."
    console.log "-- Direct S3 Serving.  HTTP-Only." if !distributions
    params = yield dns.build distributions

    try
      return false if !params
      data = yield route53.changeResourceRecordSets params
      data.ChangeInfo.Id
    catch e
      console.error "Unexpected reply while setting DNS record", e
      throw new Error()


  sync: async (id) ->
    if id
      console.log "-- Waiting for DNS records to synchronize."
    else
      console.log "-- DNS up to date.  Skipping."
      return true

    try
      while true
        data = yield route53.getChange {Id: id}
        if data.ChangeInfo.Status == "INSYNC"
          return true
        else
          yield sleep 5000
    catch e
      console.error "Unexpected reply while checking sync of DNS record.", e
      throw new Error()
