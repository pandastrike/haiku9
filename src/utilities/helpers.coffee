import Crypto from "crypto"
import {parse, join} from "path"
import {stat} from "panda-quill"
import {first} from "panda-parchment"

defaultExtension = ".html"

usesDefaultExtension = (key) -> parse(key).ext == defaultExtension

stripExtension = (key) ->
  {name, dir} = parse key
  join dir, name

exists = (path) ->
  new Promise (resolve, reject) ->
    fs path, (err) ->
      if err? then resolve false else resolve true

startsWithUnderscore = (path) ->
  {name} = parse path
  (first name) == "_"

# NOTE: S3 object PUT wants base64 encoded md5, but returns hex md5 ETags.
md5 = (buffer) ->
  Crypto.createHash('md5').update(buffer).digest("hex")

isTooLarge = (path) ->
  {size} = await stat path
  if size > 4999999999
    console.error "WARNING: The file #{path} is larger than 5GB and is
    too large to store within a single S3 object.  Haiku9 currently
    does not support multi-object files, so it is skipping this file
    during the sync."

    true
  else
    false

# CloudFormation stack names must be [A-Za-z0-9-] and less than 128 characters
generateStackName = (name) -> name.replace(/\./g, "-")[...128]

export {defaultExtension, usesDefaultExtension, stripExtension, startsWithUnderscore, exists, md5, isTooLarge, generateStackName}
