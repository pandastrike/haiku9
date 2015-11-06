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

## Configuration

At the root of your site, create a `h9.yaml` file. That should have the following settings:

- `source` — the path to the directory containing your site's source files

- `target` — the path to the directory where you want to put the compiled assets

- `server` — the server configuration (see below)

- `blog` — the blog configuration (see below)

### Server Configuration

- `port` — the port the server runs on

### Blog Configuration

- `page.size` — the number of post excerpts per page

## Running the Server

During the development, you'll want to run a simple static server.

```shell
$ h9 serve
```

## Compilation

Once you're ready, you want to compile all your assets.

```shell
$ h9 build
```

## Rendering Rules

- Anything with an underscore is skipped. Everything else is processed.

- YAML files are added to the context (locals) available in Jade.

- Markdown files look for a Jade `_layout` file to use as a rendering context.

## More on the Rendering Context

Data files for the entire site are available in the rendering context, as well as the current directory. So if you have a `_site.yml` file in your root directory, that will be accessible as the `site` variable in Jade.

Additionally, the relative path (sans extension) is mapped to a corresponding YAML file, if possible. Thus, you can access data specific to a given asset. For example, if you have an asset with the relative path of `posts/my-blog-post`, you can provide data for it in a `posts/_my-blog-post.yaml` file.

## Markdown Rendering

Markdown files will look for a `_layout.jade` file in the current directory. The Jade template should have a `content` block.
