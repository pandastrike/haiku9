{async, empty} = require "fairmont"
{randomKey} = require "key-forge"

config = require "../../../configuration"

# Prepare invalidation task to send to the CDN.  Because we are charged per
# path we specify, it's cheapest to just invalidate everything unless nothing
# changed.
module.exports = async (cf, distribution, dlist, ulist) ->

  createInvalidation = async (changes)->
    yield cf.createInvalidation
      DistributionId: distribution.Id
      InvalidationBatch:
        CallerReference: "Haiku" + randomKey 32
        Paths:
          Quantity: 1
          Items: ["/*"]

  try
    changeList = dlist
    changeList.push item.split(".html")[0] for item in ulist
    return null if empty changeList
    {Invalidation} = yield createInvalidation changeList

  catch e
    console.error "Unexpected response while setting invalidation.", e
    throw new Error()
