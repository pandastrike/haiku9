import Crypto from "crypto"
import {parse, join} from "path"

# NOTE: S3 object PUT wants base64 encoded md5, but returns hex md5 ETags.
md5 = (buffer) ->
  Crypto.createHash('md5').update(buffer).digest("hex")

isReadableFile = (path) -> (parse path).name[0] != "-"

strip = (key) ->
  {name, dir, ext} = parse key
  if ext == ".html" then join dir, name else key

export {md5, isReadableFile, strip}
