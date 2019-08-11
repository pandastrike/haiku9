import {spawn} from "child_process"
import moment from "moment"
import "moment-duration-format"
import {w} from "panda-parchment"
import {mkdirp, rmr} from "panda-quill"

bell = '\u0007'

stopwatch = ->
  start = Date.now()
  ->
    d = moment.duration Date.now() - start
    if 0 < d.asSeconds() <= 60
      d.format("s[ s]", 1)
    else if 60 < d.asSeconds() < 3600
      d.format("m:ss[ min]", 0)
    else
      d.format("h:mm[ hr]", 0)

logger = ->
  originalError = console.error
  __now = ->
    "[" + moment().format("HH:mm:ss").grey + "] "
  console.log = (args...) ->
    originalError __now() + "[H9]".green, args...
  console.warn = (args...) ->
    originalError __now() + "[H9]".yellow, args...
  console.error = (args...) ->
    originalError __now() + "[H9]".red, args...


print = (ps) ->
  ps.stdout.on "data", (data) -> process.stdout.write data.toString()
  ps.stderr.on "data", (data) -> process.stderr.write data.toString()
  ps.on "error", (error) -> console.error error

shell = (str) ->
  [command, args...] = w str
  print await spawn command, args


clean = -> await rmr "haiku9-deploy"

copy = (source, target) -> await shell "cp #{original} #{target}"

compile = (source, target) ->
  await mkdirp target "0777"
  await shell "cp -R #{source} #{target}"

  template = await read resolve target, "environment.hbs"





# Make a directory at the specified path if it doesn't already exist.
safe_mkdir = (path, mode) ->
  if await exists path
    console.error "Warning: #{path} exists. Skipping."
    return

  mode ||= "0777"
  await mkdirp mode, path

# Copy a file to the target, but only if it doesn't already exist.
safe_cp = (original, target) ->
  if await exists target
    console.error "Warning: #{target} exists. Skipping."
    return

  if await isDirectory original
    await shell "cp -R #{original} #{target}"
  else
    await shell "cp #{original} #{target}"

export {bell, stopwatch, logger}
