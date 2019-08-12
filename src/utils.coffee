import {spawn} from "child_process"
import {resolve as resolvePath} from "path"
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
  new Promise (resolve, reject) ->
    ps.stdout.on "data", (data) -> process.stdout.write data.toString()
    ps.stderr.on "data", (data) -> process.stderr.write data.toString()
    ps.on "error", (error) ->
      console.error error
      reject()
    ps.on "close", (exitCode) ->
      if exitCode == 0
        resolve()
      else
        console.error "Exited with non-zero code, #{exitCode}"
        reject()


shell = (str, path) ->
  [command, args...] = w str
  if path
    await print await spawn command, args, cwd: resolvePath process.cwd(), path
  else
    await print await spawn command, args, cwd: resolvePath process.cwd()


export {bell, stopwatch, logger, shell}
