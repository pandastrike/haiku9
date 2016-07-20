{buildAndVerify} = require './helpers/build_helpers'

Amen = require "amen"

Amen.describe "Haiku9 static-site generation", (context) ->
  context.test "Compile Stylus files", ->
    yield buildAndVerify "stylus", "site.css"


