{buildAndVerify} = require './helpers/build_helpers'

Amen = require "amen"

Amen.describe "Haiku9 static-site generation", (context) ->
  context.test "Passes through xml files", ->
    yield buildAndVerify "xml", "browserconfig.xml"
