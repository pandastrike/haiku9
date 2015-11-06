{readFileSync} = require "fs"
yaml = require "js-yaml"

module.exports = yaml.safeLoad (readFileSync "h9.yaml").toString()
