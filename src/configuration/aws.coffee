import SDK from "aws-sdk"
import Sundog from "sundog"

setupSDK = (config) ->
  profile = config.options.profile ? "default"

  console.log "H9: Using profile \"#{profile}\""
  SDK.config =
    credentials: new SDK.SharedIniFileCredentials {profile}
    region: config.region
    sslEnabled: true

  config.sundog = Sundog(SDK).AWS

  config

export default setupSDK
