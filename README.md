# Haiku9

This is a simple asset compiler. The main thing is that it's simple and you can use it independent of anything else.

## Example

Here's a simple Web server that handles requests for HTML assets. We use the `globFileForFormat` method to map request URLs to local files. This will return any files that can be rendered into the given format (in this case, `html`).

```coffee-script
http = require "http"
URL = require "url"
{dirname, basename, extname, join} = require "path"

Asset = require "haiku9"

http.createServer (request, response) ->

  # Is this a request for an HTML asset?
  if request.method is "GET" and request.headers.accept.match /html/

    # Parse out the directory and filename
    path = URL.parse(request.url).pathname[1..]
    directory = join __dirname, dirname path
    extension = extname path
    name = basename path, extension
    if name is "" then name = "index"

    # Find the corresponding asset from the local filesystem
    Asset.globNameForFormat directory, name, "html"

    .then (asset) ->

      # Render it to HTML
      asset.render "html"
      .then (html) -> response.end html, 200

      # Render error!
      .catch (error) ->
        response.end "Unknown server error: #{request.url}", 500

    # We were unable to find a corresponding asset
    .catch -> response.end "Not found: #{request.url}", 404

.listen 1337
```

## Features

* Front-matter supported for any format
* Extensible format support: just call `Asset.registerFormatter` and (if necessary) `Asset.registerExtension`
* Built-in support for Markdown, CoffeeScript, Jade, Stylus, and Markdown


## Install

    npm install haiku9

## Reference

### Class Methods

#### read(path)

Reads the file at the given path. Returns a promise. The success handler takes the Asset instance corresponding to the file.

#### readFiles(files)

Reads the given files. Returns a promise. The success handler takes an array of Asset instances corresponding to the files.

#### readDir(path)

Reads the files in the directory at the given path. Returns a promise. The success handler takes an array of Asset instances corresponding to the files within the directory.

#### glob(path, pattern)

Reads the files in the path based on the glob pattern. Returns a promise. The success handler takes an array of Asset instances corresponding to the matching files within the directory.

##### Example

Return all the markdown blog posts:

```coffee-script
Asset.glob "posts", "*.md"
```

#### globForFormat(path, format)

Reads the files in the path that can be rendered into the given format. Returns a promise. The success handler takes an array of Asset instances corresponding to the matching files within the directory.

##### Example

Return all the blog posts regardless of format:

```coffee-script
Asset.globForFormat "posts", "html"
```

#### globNameForFormat(path, name, format)

Reads the file corresponding to the given path and name that can be rendered into the given format. The success handler takes the matching Asset instance.

##### Example

Return the `index.html` asset, regardless of source format:

```coffee-script
Asset.globNameForFormat docRoot, "index", "html"
```

#### registerFormatter(spec, formatter)

Register a formatter. The spec is an object with `to` and `from` properties. The `formatter` is a function. The formatter function should return a promise.

##### Example

```coffee-script
Asset.registerFormatter
  to: "html"
  from:  "jade"
  (markup, context) ->
    context.cache = true
    attempt(jade.renderFile, context.filename, context)
```

#### registerExtension(spec)

Register an extension correspoding to a format. The spec is an object with `format` and `extension` properties.

##### Example

Asset.registerExtension extension: "md", format: "markdown"

### Instance Methods

#### constructor(path, content)

An Asset constructor takes a path to the source file and the content of the file. The path is parsed to extract a `key` property for the asset and its `format`. The content is parsed for front-matter.

#### render(format, [context])

Render the asset into the given format. Optionally, you can pass in a context. If the associated formatter supports it, the context will be available when rendering. Returns a promise. The success handler returns the result of the render.
