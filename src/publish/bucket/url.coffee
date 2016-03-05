# Helper functions to assist with url manipulation for AWS calls.
{last} = require "fairmont"
config = require "../../configuration"

module.exports = do ->
  # Enforces "fully qualified" form of hostnames and domains.  Idompotent.
  fullyQualify = (name) -> if last(name) == "." then name else name + "."

  # Named somewhat sarcastically.  Enforces "regular" form of hostnames
  # and domains that is more expected when navigating.  Idompotnent.
  regularlyQualify = (name) -> if last(name) == "." then name[...-1] else name

  # Given an arbitrary URL, return the fully qualified root domain.
  # https://awesome.example.com/test/42#?=What+is+the+answer  =>  example.com.
  root = (url) ->
    try
      # Remove protocol (http, ftp, etc.), if present, and get domain
      domain = url.split('/')
      domain = if "://" in url then domain[2] else domain[0]

      # Remove port number, if present
      domain = domain.split(':')[0]

      # Now grab the root: the top-level-domain, plus the term to the left.
      terms = regularlyQualify(domain).split(".")
      terms = terms.slice(terms.length - 2)

      # Return the fully qualified version of the root
      fullyQualify terms.join(".")
    catch e
      console.error "Failed to parse root url", e
      throw new Error()

  # From the bucket name and region, we can construct the bucket's URL.
  # We construct the region-specific endpoint. AWS docs make a vague reference
  # to its ability to "reduce data latency", but it's not clear how many ms
  # we are saving in the response time.
  bucketURL = -> "s3-website-" + config.s3.region + ".amazonaws.com."

  {bucketURL, fullyQualify, regularlyQualify, root}
