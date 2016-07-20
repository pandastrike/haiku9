{build, isBuilt} = require "./helpers/build_helpers"

{join} = require "path"
assert = require "assert"
{chdir, promise} = require "fairmont"
http = require "http"
childProcess = require "child_process"
Amen = require "amen"

SERVE_FILE = join __dirname, "helpers", "server.coffee"
SERVE_STARTUP_TIMEOUT = 5000

Amen.describe "Haiku9 serve task", (context) ->
  context.test "Starts a local server on the default port", ->
    # Build the jade fixture if needed
    unless yield isBuilt "jade", "index.html"
      yield build "jade"

    # CD into the jade fixture to run it
    child = null
    chdir join(__dirname, "fixtures", "jade"), ->
      child = childProcess.fork(SERVE_FILE)

    # Give the server a few seconds to spin up (but resolve immediately when you can)
    start = now = new Date()
    while now - start < SERVE_STARTUP_TIMEOUT
      try
        statusCode = yield promise (resolve, reject) ->
          http.get "http://localhost:8080", (response) ->
            resolve(response.statusCode)
          .on 'error', (err) ->
            reject()
        break
      catch
        now = new Date()

    # Kill the server process
    child.kill()

    assert statusCode?, "Server did not respond"
    assert statusCode is 200, "Expected status 200, got #{statusCode}"
