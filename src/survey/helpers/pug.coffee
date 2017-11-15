{pug} = require "panda-9000"

module.exports = (source) ->
  options =
    filters:
      "markdown-it": (text) ->
        md = do require "markdown-it"
        md.use require "markdown-it-inline-comments"
        md.render text

  options.basedir = source if source

  pug options
