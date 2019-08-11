{spawn} = require "child_process"
{resolve: resolvePath} = require "path"
{tools} = require "panda-builder"
p9k = require "panda-9000"
{define} = require "panda-9000"
{w} = require "panda-parchment"
{rmr, mkdirp} = require "panda-quill"

{target} = tools p9k

target "npm"

process.on "unhandledRejection", (reason, p) ->
  console.error "Error:", reason


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
  print await spawn command, args, cwd: resolvePath process.cwd(), path

define "edge:clean", ->
  await rmr "files/default-lambdas"
  await mkdirp "0777", "files/default-lambdas/primary"
  await mkdirp "0777", "files/default-lambdas/secondary/origin-request/lib"

define "edge:build", [ "edge:clean" ], ->
  await shell "npm run build", "edge-lambdas/primary/viewer-request"
  await shell "npm run build", "edge-lambdas/primary/origin-request"
  await shell "npm run build", "edge-lambdas/secondary/origin-request"
