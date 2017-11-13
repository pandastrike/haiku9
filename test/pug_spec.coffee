{buildAndVerify} = require './helpers/build_helpers'

Amen = require "amen"

Amen.describe "Haiku9 static-site generation", (context) ->
  context.test "Compiles Pug files", ->
    yield buildAndVerify "pug", "index.html"
