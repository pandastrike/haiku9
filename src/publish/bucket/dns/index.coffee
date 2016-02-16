{async, sleep} = require "fairmont"

config = require "../../../configuration"

# Handles setting up DNS records to assign the desired hostname to the bucket.
module.exports = (route53) ->

  set: async ->
    params = yield do require("./setup")(route53)

    try
      return null if !params
      data = yield route53.changeResourceRecordSets params
      data.ChangeInfo.Id
    catch e
      console.error "Unexpected reply while setting DNS record", e
      throw new Error()


  sync: async (id) ->
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
