import SDK from "aws-sdk"
import Sundog from "sundog"

setEnvironment = (config) ->
  config.environment = config.environments[config.env]

  unless config.environment?
    throw new Error "No configuration for '#{config.env}'"


  profile = config.options.profile ? "default"

  console.error "H9: Using profile \"#{profile}\""
  SDK.config =
    credentials: new SDK.SharedIniFileCredentials {profile}
    region: config.region
    sslEnabled: true

  config.sundog = Sundog(SDK).AWS

  config

export default setEnvironment
