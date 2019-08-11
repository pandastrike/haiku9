import moment from "moment"
import "moment-duration-format"

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

export {bell, stopwatch, logger}
