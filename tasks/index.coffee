{tools} = require "panda-builder"
p9k = require "panda-9000"

{target} = tools p9k

target "npm"

process.on "unhandledRejection", (reason, p) ->
  console.error "Unhandled Rejection", reason
