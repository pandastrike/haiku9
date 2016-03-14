{join} = require "path"

process.chdir join __dirname, "..", "examples", "simple-site"
require "../src/index"

{run} = require "panda-9000"
assert = require "assert"
{shell, sleep, call, exists} = require "fairmont"
Amen = require "amen"

Amen.describe "Haiku9 static-site generation", (context) ->

  context.test "Run the build task", ->
    yield shell "rm -rf build"
    yield run "build"
    yield sleep 1000
    assert yield exists "build"

    context.test "Compile Jade files", ->
      assert yield exists "build/index.html"

    context.test "Compile Stylus files", ->
      assert yield exists "build/site.css"

    context.test "Compile CoffeeScript files", ->
      assert yield exists "build/site.js"
