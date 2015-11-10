{join} = require "path"
marked = require "marked"
{reactor, pull, go, collect, partition, map, tee,
async, include, Type, isType,
read, glob,
Method} = require "fairmont"
{define} = Method
{task, context, jade} = require "panda-9000"
{find, save, render} = Asset = require "../asset"
{source, blog} = require "../configuration"
Data = require "../data"

_reverse = (array) -> array.reverse()
reverse = (r) ->
  items = undefined
  reactor async ->
    items ?= _reverse yield collect r
    if items.length == 0
      done: true
    else
      done: false, value: items.shift()

type = Type.define Asset

task "survey/posts", "survey/markdown", ->
  go [
    glob "posts/*.md", source
    map context source
    map ({path}) -> {path, extension: ".html"}
    map Asset.find
    reverse
    partition blog.page.size
    (r) ->
      pages = last = undefined
      n = 0
      reactor async ->
        pages ?= yield collect r
        last ?= pages.length - 1
        if pages.length == 0
          done: true
        else
          items = pages.shift()
          asset = include (Type.create type),
            path: if n == 0 then "blog/index" else "blog/#{n}"
            source:
              path: join source, "blog/_page.jade"
            target:
              extension: ".html"
            data:
              items: items
              next: if n < last then "/blog/#{n + 1}"
              previous:
                switch n
                  when 0 then undefined
                  when 1 then "/blog/index"
                  else "/blog/#{n - 1}"
          Data.augment asset
          n++
          {done: false, value: asset}
    tee save
  ]

define render, (isType type), async (asset) ->
  for item in asset.data.items
    markdown = (yield read item.source.path).split( "<!-- more -->")[0]
    item.excerpt = marked markdown
  jade asset
