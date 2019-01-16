import {parse} from "path"
import {stat} from "panda-quill"

defaultExtension = ".html"

usesDefaultExtension = (key) -> parse(key).ext == defaultExtension

stripExtension = (key) -> parse(key).name

exists = (path) ->
  new Promise (resolve, reject) ->
    fs path, (err) ->
      if err? then resolve false else resolve true

md5 = (buffer) ->
  Crypto.createHash('md5').update(buffer).digest("base64")

isTooLarge = (path) ->
  {size} = await stat path
  if size > 4999999999
    console.warn "The file #{path} is larger than 5GB and is too large to
    store within a single S3 object.  Haiku9 currently does not support
    multi-object files, so it is skipping this file during the sync."
    true
  else
    false

export {defaultExtension, usesDefaultExtension, stripExtension, exists, md5, isTooLarge}
