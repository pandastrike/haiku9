import SDK from "aws-sdk"
import Sundog from "sundog"

setupSDK = (config) ->
  profile = config.profile ? "default"
  SDK.config =
    credentials: new SDK.SharedIniFileCredentials {profile}
    region: config.aws.region
    sslEnabled: true

  Sundog(SDK).AWS

export default setupSDK
