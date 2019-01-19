import Local from "./local"
import Bucket from "./bucket"
import Edge from "./edge"

Utilities = (config) ->
  local = Local config
  bucket = Bucket config
  edge = await Edge config

  {local, bucket, edge}

export default Utilities
