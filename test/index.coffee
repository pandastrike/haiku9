{join, resolve} = require "path"
Asset = require "../src/asset"
root = resolve(__dirname)
amen = require "amen"
assert = require "assert"

amen.describe "Asset", (context) ->
  context.test "Read an asset file", (context) ->
    Asset.read join(root, "files", "a.md")
    .success (asset) ->
      context.pass ->
        assert.equal asset.key, "a"
        assert.equal asset.format, "markdown"
        assert.equal asset.render?, true
    .error (error) -> context.fail(error)

  context.test "Read an asset directory", (context) ->
    Asset.readDir join(root, "files")
    .success (assets) ->
      context.pass ->
        assert.equal Object.keys(assets).length, 2
    .error (error) -> context.fail(error)

  context.test "Glob an asset directory", (context) ->
    Asset.glob join(root, "files"), "*"
    .success (assets) ->
      context.pass ->
        assert.equal Object.keys(assets).length, 2
    .error (error) -> context.fail(error)

  context.test "Glob an asset directory for a given format", (context) ->
    Asset.globForFormat join(root, "files"), "html"
    .success (assets) ->
      context.pass ->
        assert.equal Object.keys(assets).length, 2
    .error (error) -> context.fail(error)
