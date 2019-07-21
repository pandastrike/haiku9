import {relative, join, parse} from "path"
import {second} from "panda-parchment"
import {lsR, read, exists} from "panda-quill"
import {strip, tripleJoin, md5, isReadableFile} from "./helpers"

scanLocal = (config) ->
  console.log "H9: scanning local files"
  config.local = hashes: {}

  for path in (await lsR config.source) when isReadableFile path
    config.local.hashes[relative config.source, path] =
      md5 (await read path, "buffer"), "hex"

  config

# Task queue for Haiku9. Local file tree is authoritative.
reconcile = (config) ->
  {source, local, remote} = config
  config.tasks = deletions: [], uploads: []

  isFilePresent = (key) -> local[key]? || local[key + ".html"]?
  isDirPresent = (key) -> exists join source, key
  isCurrent = (key, hash) ->
    if remoteHash = remote[key] || remote[strip key]
      hash == remoteHash
    else
      false

  for key of remote.hashes when !(isFilePresent key)
    config.tasks.deletions.push key

  for key in remote.directories when !(await isDirPresent key)
    config.tasks.deletions.push key

  for key, hash of local.hashes when !(isCurrent key, hash)
    config.tasks.uploads.push key

  config

export {scanLocal, reconcile}
