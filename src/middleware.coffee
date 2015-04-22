{async} = require "fairmont"
{compile, clean} = require "./compile"

create = async (source, destination) ->
  # do an initial build, set up watchers and mtime cache
  yield clean destination
  yield compile source, destination

  # the actual middleware itself is a no-op
  # perhaps it shouldn't even be done like this,
  # it's a legacy of how I started coding it
  (request, response, next) -> next()

module.exports = {create}
