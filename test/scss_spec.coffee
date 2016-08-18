{buildAndVerify} = require './helpers/build_helpers'

Amen = require "amen"

Amen.describe "Haiku9 static-site generation", (context) ->
  context.test "Compiles SCSS files", ->
    yield buildAndVerify "scss", "scss-styles.css"
