[![Build Status](https://travis-ci.org/pandastrike/haiku9.svg)](https://travis-ci.org/pandastrike/haiku9)

# Haiku9

Haiku9 (H9 for short) is a static site generator. H9 supports:

* Jade templates
* Markdown
* CoffeeScript
* Stylus
* Image files

H9 works by using [Panda-9000](https://github.com/pandastrike/panda-9000)
to define a series of asset pipelines.

H9 provides a build command and simple Web server for development.

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

## Development Server

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

- For Jade and Stylus, anything with an underscore is skipped.

- YAML files are added to the context (locals) available in Jade.

- Markdown files look for a Jade `_layout` file to use as a rendering context.

## More on the Rendering Context

Data files for the entire site are available in the rendering context, as well as the current directory. So if you have a `_site.yml` file in your root directory, that will be accessible as the `site` variable in Jade.

Additionally, the relative path (sans extension) is mapped to a corresponding YAML file, if possible. Thus, you can access data specific to a given asset. For example, if you have an asset with the relative path of `posts/my-blog-post`, you can provide data for it in a `posts/_my-blog-post.yaml` file.

## Markdown Rendering

Markdown files will look for a `_layout.jade` file in the current directory. The Jade template should have a `content` block.

## Motivation

Why another static site generator? Mostly because, believe it or not, we could not find the particular set of features we wanted, and we wanted those features badly enough to write Haiku9.

Foremost among them was a desire to be able to easily hack new features. Haiku9's design is made simple by effectively being nothing more than an opinionated configuration of Panda-9000. That is, it's just a bunch of asset compilation tasks. New pipelines are easy to add.

Some specific things we wanted, most of which exist somewhere, just not together in an hackable (for us, anyway) form:

- All content (even the data) should be file-based so we can use our existing Git workflow to collaborate on the site

- Integration of external data files (as opposed to front-matter)

- Use of YAML (not JSON) for data and configuration files

- Leverage template language features for composing templates (instead of providing JavaScript helpers that impose their own composition model)

- Emphasis on: Jade, Stylus, Markdown, and CoffeeScript

- Direct support for publishing to S3/CloudFront

- Support for typographically processing HTML

- Support for on-the-fly image compression
