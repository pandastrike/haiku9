{pug} = require "panda-9000"

module.exports = (source) ->
  options =
    filters:
      "markdown-it": (text) ->
        md = require("markdown-it")()
        .use require "markdown-it-inline-comments"
        .use require "markdown-it-anchor"
        .render text

  options.basedir = source if source

  pug options
