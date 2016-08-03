require "../../src/index"

{join} = require "path"
assert = require "assert"
childProcess = require 'child_process'
{shell, call, exists, chdir, promise} = require "fairmont"

HOME_DIR = join __dirname, "..", ".."
BASE_FIXTURE_DIR = join HOME_DIR, "test", "fixtures"
BUILD_FILE = join __dirname, "builder.coffee"

BUILD_TIMEOUT = 5000

fixtureDir = (fixture) ->
  join BASE_FIXTURE_DIR, fixture

moveTo = (fixture) ->
  chdir fixtureDir(fixture)

moveHome = ->
  chdir HOME_DIR

# Accepts the name of a fixture, which must match up to
# a directory in the test/fixtures directory.
# Runs the `build` task on that directory.
build = (fixture) ->
  call ->
    moveTo fixture
    yield shell "rm -rf build"
    moveTo fixture
    yield promise (resolve, reject) ->
      child = childProcess.fork(BUILD_FILE)
      child.on 'exit', -> resolve()
    moveHome()

# Predicate, returns true if the `expectedFile` exists
# under the fixture's build directory
isBuilt = (fixture, expectedFile) ->
  fullPath = join fixtureDir(fixture), "build", expectedFile
  call -> yield exists fullPath

# Asserts that the given test file exists under the fixture's build directory
assertBuilt = (fixture, expectedFile) ->
  call ->
    start = now = new Date()
    built = false
    while now - start <= BUILD_TIMEOUT
      if built = yield isBuilt(fixture, expectedFile)
        break
      else
        now = new Date()

    assert built, "File #{expectedFile} not built"

buildAndVerify = (fixture, expectedFile) ->
  call ->
    yield build fixture
    yield assertBuilt fixture, expectedFile

module.exports =
  build: build
  isBuilt: isBuilt
  assertBuilt: assertBuilt
  buildAndVerify: buildAndVerify
