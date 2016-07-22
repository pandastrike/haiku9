{build, buildAndVerify, assertBuilt, assertContent, assertNoContent} = require './helpers/build_helpers'

assert = require "assert"
Amen = require "amen"

Amen.describe "Haiku9 static-site generation", (context) ->
  context.test "Compiles handlebars files", ->
    yield build "handlebars"
    yield assertBuilt "handlebars", "page-hb.html"
    # Verify compilation of handlebars logic
    yield assertContent "handlebars", "page-hb.html", "TRUE BLOCK"
    yield assertNoContent "handlebars", "page-hb.html", "FALSE BLOCK"

    yield assertBuilt "handlebars", "page-hbs.html"
    # Verify compilation of handlebars logic
    yield assertContent "handlebars", "page-hbs.html", "TRUE BLOCK"
    yield assertNoContent "handlebars", "page-hbs.html", "FALSE BLOCK"

    yield assertBuilt "handlebars", "page-handlebars.html"
    # Verify compilation of handlebars logic
    yield assertContent "handlebars", "page-handlebars.html", "TRUE BLOCK"
    yield assertNoContent "handlebars", "page-handlebars.html", "FALSE BLOCK"

  context.test "Includes swag helpers", ->
    yield buildAndVerify "handlebars", "page-with-swag.html"
    # Using panda-template to compile handlebars files, so it should
    # automatically include swag helpers. The `page-with-swag.hb` template
    # includes a reference to the `now` helper, so we should see
    # a formatted version of the current date in the file
    now = new Date()
    expectedContent = "#{now.getDate()}/#{now.getFullYear()}"
    yield assertContent "handlebars", "page-with-swag.html", expectedContent

  context.test "Merges data from YAML", ->
    yield buildAndVerify "handlebars", "page-with-data.html"
    yield assertContent "handlebars", "page-with-data.html", "I'm a value from YAML!"

