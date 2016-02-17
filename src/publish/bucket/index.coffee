{call} = require "fairmont"

module.exports = call ->

  {route53, s3} = yield require "../../aws"

  dns: require("./dns")(route53)
  scan: require("./scan")(s3)
  sync: require("./sync")(s3)
  web: require("./web")(s3)
