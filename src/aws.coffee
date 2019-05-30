import SDK from "aws-sdk"
import Sundog from "sundog"

setupSDK = (config, profile="default") ->
  console.log "Using profile \"#{profile}\""
  SDK.config =
    credentials: new SDK.SharedIniFileCredentials {profile}
    region: config.region
    sslEnabled: true

  config.sundog = Sundog(SDK).AWS

export default setupSDK
