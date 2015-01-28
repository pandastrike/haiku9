{join, resolve} = require "path"
Asset = require "../src/asset"
root = resolve(__dirname)
amen = require "amen"
assert = require "assert"
data = require "./data"

amen.describe "Asset", (context) ->
  context.test "Read an asset file", (context) ->
    Asset.read join(root, "files", "a.md")
    .then (asset) ->
      context.pass ->
        assert.equal asset.key, "a"
        assert.equal asset.format, "markdown"
        assert.equal asset.render?, true
    .catch (error) -> context.fail(error)

  context.test "Read an asset directory", (context) ->
    Asset.readDir join(root, "files")
    .then (assets) ->
      context.pass ->
        assert.equal Object.keys(assets).length, 4
    .catch (error) -> context.fail(error)

  context.test "Glob an asset directory", (context) ->
    Asset.glob join(root, "files"), "*"
    .then (assets) ->
      context.pass ->
        assert.equal Object.keys(assets).length, 4
    .catch (error) -> context.fail(error)

  context.test "Glob an asset directory for a given format", (context) ->
    Asset.globForFormat join(root, "files"), "html"
    .then (assets) ->
      context.pass ->
        assert.equal Object.keys(assets).length, 2
    .catch (error) ->
      context.fail(error)

  context.test "Render markdown file", (context) ->
    Asset.globNameForFormat join(root, "files"), "a", "html"
    .then (asset) ->
      asset.render("html")
      .then (html) ->
        context.pass ->
          assert.equal html, data.a.html
    .catch (error) ->
      context.fail(error)

  context.test "Render jade file", (context) ->
    Asset.globNameForFormat join(root, "files"), "b", "html"
    .then (asset) ->
      asset.render("html")
      .then (html) ->
        context.pass ->
          assert.equal html, data.b.html
    .catch (error) ->
      context.fail(error)

  context.test "Render stylus file", (context) ->
    Asset.globNameForFormat join(root, "files"), "c", "css"
    .then (asset) ->
      asset.render("css")
      .then (css) ->
        context.pass ->
          assert.equal css, data.c.css
    .catch (error) ->
      context.fail(error)

  context.test "Render coffeescript file", (context) ->
    Asset.globNameForFormat join(root, "files"), "d", "javascript"
    .then (asset) ->
      asset.render("javascript")
      .then (js) ->
        context.pass ->
          assert.equal js, data.d.js
    .catch (error) ->
      context.fail(error)