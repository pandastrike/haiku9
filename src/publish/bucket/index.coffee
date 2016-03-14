{async} = require "fairmont"

module.exports = async (config) ->

  {cf, route53, s3} = yield require("../../aws")()

  cf: yield require("./cloudfront")(config, cf)
  dns: require("./dns")(config, route53)
  scan: require("./scan")(config, s3)
  sync: require("./sync")(config, s3)
  web: require("./web")(config, s3)
