targets = process.argv[2..]

if targets.length is 0
  targets = [
    "coffeescript"
    "handlebars"
    "jade"
    "json"
    "scss"
    "serve"
    "stylus"
    "xml"
  ]

require "./#{target}_spec" for target in targets
