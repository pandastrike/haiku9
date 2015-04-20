{join, resolve} = require "path"
Asset = require "../src/asset"
root = resolve(__dirname)
amen = require "amen"
assert = require "assert"
data = require "./data"

amen.describe "Asset", (context) ->

  context.test "Read an asset file", ->
    asset = yield Asset.read join(root, "files", "a.md")
    assert asset.key == "a"
    assert asset.format == "markdown"
    assert asset.render?
    assert asset.data.title == "Test Post"

  context.test "Read an asset directory", ->
    assets = yield Asset.readDir join(root, "files")
    assert Object.keys(assets).length == 4

  context.test "Glob an asset directory", ->
    assets = yield Asset.glob join(root, "files"), "*"
    assert Object.keys(assets).length == 4

  context.test "Glob an asset directory for a given format", ->
    assets = yield Asset.globForFormat join(root, "files"), "html"
    assert Object.keys(assets).length == 2

  context.test "Render markdown file", ->
    asset = yield Asset.globNameForFormat join(root, "files"), "a", "html"
    html = yield asset.render "html"
    assert html == data.a.html

  context.test "Render jade file", ->
    asset = yield Asset.globNameForFormat join(root, "files"), "b", "html"
    html = yield asset.render "html"
    assert html == data.b.html

  context.test "Render stylus file", ->
    asset = yield Asset.globNameForFormat join(root, "files"), "c", "css"
    css = yield asset.render "css"
    assert css == data.c.css

  context.test "Render coffeescript file", ->
    asset = yield Asset.globNameForFormat join(root, "files"), "d", "javascript"
    js = yield asset.render "javascript"
    assert js == data.d.js
