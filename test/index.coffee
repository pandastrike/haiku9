{join, resolve} = require "path"
Asset = require "../src/asset"
root = resolve(__dirname)

Asset.events.on "error", (error) -> console.log error
Asset.read join(root, "files", "a.md")
.on "success", (asset) ->
  console.log asset

Asset.readDir join(root, "files")
.on "success", (assets) ->
  for file, asset of assets
    asset.render "html"
    .on "success", (html) ->
      console.log html

Asset.glob(join(root, "files"), "*")
.on "success", (assets) ->
  for file, asset of assets
    asset.render "html"
    .on "success", (html) ->
      console.log html
