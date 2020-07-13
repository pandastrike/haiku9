import {resolve} from "path"
import SDK from "aws-sdk"
import Sundog from "sundog"
import {exists} from "panda-quill"

setEnvironment = (config) ->
  config.environment = config.environments[config.env]

  unless config.environment?
    throw new Error "No configuration for '#{config.env}'"

  if config.site?.index?
    path = resolve config.source, config.site.index
    unless await exists path
      throw new Error "index file at #{path} does not exist"

  if config.site?.error?
    path = resolve config.source, config.site.error
    unless await exists path
      throw new Error "error file at #{path} does not exist"


  profile = config.options.profile ? "default"

  console.log "Using profile \"#{profile}\""
  SDK.config =
    credentials: new SDK.SharedIniFileCredentials {profile}
    region: config.region
    sslEnabled: true

  config.sundog = Sundog(SDK).AWS

  config

export default setEnvironment
