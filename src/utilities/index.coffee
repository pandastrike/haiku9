import setupSDK from "./aws"
import Local from "./local"
import Bucket from "./bucket"
import Edge from "./edge"
import DNS from "./dns"

Utilities = (config) ->
  local = Local config
  bucket = Bucket config
  edge = await Edge config

  {local, bucket, edge}
