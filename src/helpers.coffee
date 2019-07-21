import Crypto from "crypto"
import zlib from "zlib"
import {parse, join} from "path"
import {stat} from "panda-quill"

# NOTE: S3 object PUT wants base64 encoded md5, but returns hex md5 ETags.
md5 = (buffer, encoding) ->
  switch encoding
    when "hex", "base64"
      Crypto.createHash('md5').update(buffer).digest(encoding)
    else
      throw new Error "must specify encoding for MD5 hash"

isReadableFile = (path) -> (parse path).name[0] != "-"

strip = (key) ->
  {name, dir, ext} = parse key
  if ext == ".html" then join dir, name else key

tripleJoin = (key) -> join p, key for p in ["identity", "gzip", "brotli"]

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

isCompressible = (buffer, accept) ->
  return false if buffer.length < 1000
  return true if (/^application\/json$/.test accept) ||
    (/^application\/javascript$/.test accept) ||
    (/^text\//.test accept) ||
    (/^image\/svg/.test accept)

  false

gzip = (buffer) ->
  new Promise (resolve, reject) ->
    zlib.gzip buffer, level: 9, (error, result) ->
      if error
        reject error
      else
        resolve result

brotli = (buffer) ->
  new Promise (resolve, reject) ->
    zlib.brotliCompress buffer, level: 10, (error, result) ->
      if error
        reject error
      else
        resolve resolve result

export {md5, isReadableFile, strip, tripleJoin, isTooLarge, isCompressible, gzip, brotli}
