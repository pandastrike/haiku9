import Crypto from "crypto"
import zlib from "zlib"
import JSZip from "jszip"
import {parse, join, relative, resolve} from "path"
import {stat, glob, read, write} from "panda-quill"

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
  if ext == ".html" then (join dir, name) else key

tripleJoin = (key) -> join p, key for p in ["identity", "gzip", "brotli"]

isTooLarge = (path) ->
  {size} = await stat path
  if size > 4999999999
    console.warn "The file #{path} is larger than 5 GB and is
    too large to store within a single S3 object.  Haiku9 currently
    does not support multi-object files, so it is skipping this file
    during the sync."

    true
  else
    false

lambdaSizeCheck = (type, path) ->
  {size} = await stat path
  if (/origin/.test type) && (size > 49999999)
    throw new Error "The file #{path} is larger than 50 MB and is too large for #{type} edge lambdas"
  if (/viewer/.test type) && (size > 999999)
    throw new Error "The file #{path} is larger than 1 MB and is too large for #{type} edge lambdas"

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

zip = (cwd, source, target) ->
  files = await glob "#{source}/**", cwd
  files.sort()

  Zip = new JSZip()

  for path in files
    name = relative cwd, path
    data = await read path, "buffer"
    Zip.file name, data,
      date: new Date "2019-08-12T19:17:56.050Z" # Lie to get consistent hash
      createFolders: false

  archive = await Zip.generateAsync
    type: "nodebuffer"
    compression: "DEFLATE"
    compressionOptions: level: 9

  await write (resolve cwd, target), archive

export {md5, isReadableFile, strip, tripleJoin, isTooLarge, lambdaSizeCheck,
  isCompressible, gzip, brotli, zip}
