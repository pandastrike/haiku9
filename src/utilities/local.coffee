import fs from "fs"
import mime from "mime"
import {first, second} from "panda-parchment"
import {lsR, read} from "panda-quill"
import {go} from "panda-river"
import {defaultExtensions, startsWithUnderscore, exists, md5} from "./helpers"


class FileTable
  constructor: (@table) ->

  @create: (table) -> new FileTable table

  defaultExtension: ".html"
  isPresent: (key) -> @table[key]? || @table[key + @defaultExtension]?

Utility = ({source}) ->
  # Produce a table of filenames and their md5 hashes.
  getFileTable = ->
    table = {}
    paths = await lsR source
    for path in paths when !(startsWithUnderscore path)
      content =
        if "text" in mime.getType path
          Buffer.from await read path
        else
          await read path, "buffer"

      # Remove "source" path prefix to generate S3 key.
      key = second path.split source + "/"
      table[key] = md5 content

    FileTable.create table

  # Produce a task queue to sync the S3 bucket with local files.
  # The local file tree is authoritative.
  reconcile = (local, remote) ->
    deletions = []
    uploads = []

    # Delete remote files that do not exist locally.
    for key of remote.table when !(local.isPresent key)
      deletions.push key

    # Delete remote directories that do not exist locally.
    for key in remote.directories when !(await exists join source, key)
      deletions.push key

    # Upload local files that are not current in the S3 bucket.
    for key, hash of local.table when !(remote.isCurrent key, hash)
      uploads.push key

    {deletions, uploads}

  {getFileTable, reconcile}

export default Utility
