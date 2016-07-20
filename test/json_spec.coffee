{buildAndVerify} = require './helpers/build_helpers'

Amen = require "amen"

Amen.describe "Haiku9 static-site generation", (context) ->
  context.test "Passes through json files", ->
    yield buildAndVerify "json", "manifest.json"
