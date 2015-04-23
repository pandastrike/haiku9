# Haiku9

Haiku9 is an Web asset compiler. It currently supports:

* Jade templates
* Markdown
* CoffeeScript
* Stylus

All other assets are pass-throughs.

## Installation

```shell
$ npm install -g haiku9
```

## Running the Server

During the development, you'll want to run a simple static server.

```shell
$ h9 server
```

You can see other options with the `-h` or `--help` flags.

## Compilation

Once you're ready, you want to compile all your assets.

```shell
$ h9 compile
```


You can see other options with the `-h` or `--help` flags.

## Rendering Rules

* Anything with an underscore is skipped. Everything else is processed.
* YAML files are added to the context (locals) available in Jade.
* Markdown files look for a Jade `_layout` file to use as a rendering context.

## More on the Rendering Context

Data files for the entire site are available in the rendering context, as well as the current directory. So if you have a `_site.yml` file in your root directory, that will be accessible as the `site` variable in Jade.

Similarly, if you have a directory called `posts` in your root directory which contains a file called `_data.yml`, that will be available as `posts.data` in your Jade templates. From within an asset in the `posts` directory, it can also be accessed simply as `data`.

Additionally, the `key` (aka slug) is available. Thus, you can access data specific to an asset by providing a data file with asset keys as the keys to a hash. For example, if you have an asset called `my-blog-post.md` you'd want a data file in the same directory that looks like this.

```yml
my-blog-post:
  title: "An Unfortunate Series of Events"
```

## Markdown Rendering

Markdown files will look for a `_layout.jade` file in the current directory or in an ancestor directory. The Jade template should have a `content` block.

## Known Problems

* The server watches directories for changes. This has the drawback of meaning that changes outside the directory being watched, such as to a layout file in a parent directory, won't trigger a recompilation of the affected files. The workaround for now is just to save or `touch` the file you want recompiled.

* Errors related to rendering markdown are lost. Haiku9 cannot see into the compilation process to see what went wrong. So it can only report that there was a problem. The workaround is to convert your markdown file into a Jade file temporarily to see what the problem is.

* The logging is verbose and there is no option to turn it off or down. The workaround is just redirect to `/dev/null`.

* There is no way to dynamically include content from other assets. You can do this statically, ex: `include:markdown some-markdown.md`. In most cases, between Jade's `include`, `extend`, and `mixin` features, this isn't a problem. But there are a few cases, like dynamically creating excerpts for blog posts, where it would be useful. The work around for now is to find a way to do whatever it is you're trying to do statically.
