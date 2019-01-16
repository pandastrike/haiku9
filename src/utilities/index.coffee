import setupSDK from "./aws"
import Bucket from "./bucket"
import Local from "./local"

Utilities = (config) ->
  SDK = setupSDK config
  bucket = Bucket AWS, config
  local = Local config

  {AWS, bucket, local}
