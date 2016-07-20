targets = process.argv[2..]

if targets.length is 0
  targets = [
    "build"
  ]

require "./#{target}_spec" for target in targets
