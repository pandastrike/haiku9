[![Build Status](https://travis-ci.org/pandastrike/haiku9.svg)](https://travis-ci.org/pandastrike/haiku9)

# Haiku9

Haiku9 (H9 for short) is a static site generator. H9 supports:

* Jade templates
* Markdown
* Handlebars (via [Panda Template](https://github.com/pandastrike/panda-template))
* CoffeeScript
* Stylus
* Image files

H9 works by using [Panda-9000](https://github.com/pandastrike/panda-9000)
to define a series of asset pipelines.

H9 provides a build command and simple Web server for development.

## Documentation

The [H9 docs](https://www.pandastrike.com/open-source/haiku9/) cover many details not addressed in this README.

## Installation

### Local

```shell
npm install -g haiku9
```

### Docker

```shell
docker pull pandastrike/haiku9
docker tag pandastrike/haiku9 h9
```

## Configuration

At the root of your site, create a `h9.yaml` file. That should have the following settings:

- `source` — the path to the directory containing your site's source files

- `target` — the path to the directory where you want to put the compiled assets

- `exclusions` (Array) - List of paths to exlude from the S3 synchronization process. Haiku will recursively exlcude all descedents of a specified path.

- `server` — the server configuration (see below)

- `blog` — the blog configuration (see below)

### Server Configuration

- `port` — the port the server runs on

### Exclusions Configuration

- String - the s3 path(s) you wish to excluse from the synch process

### Blog Configuration

- `page.size` — the number of post excerpts per page

## Development Server

During the development, you'll want to run a simple static server.

### Local

```shell
h9 serve
```

### Docker

```shell
docker run -it --rm -v "$PWD":/usr/src/app -p 1337:1337 h9 serve
```

NOTE: To install your app's npm modules via the `h9` Docker image:

```shell
docker run -it --rm -v "$PWD":/usr/src/app --entrypoint="npm" h9 install
```

## Compilation

Once you're ready, you want to compile all your assets.

### Local

```shell
h9 build
```

### Docker

```shell
docker run -it --rm -v "$PWD":/usr/src/app h9 build
```

## Publishing

(See the [H9 Publish Docs](https://www.pandastrike.com/open-source/haiku9/publish/) for more information).

To publish your compiled site to AWS, first confirm that your AWS credentials are defined in `~/.aws/credentials`:

  [default]
  aws_access_key_id=AKIAIOSFODNN7EXAMPLE
  aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

Next, push to AWS using one of the approaches below:

### Local

```shell
h9 publish <environment>
```

### Docker

```shell
docker run -it --rm -v "$PWD":/usr/src/app -v ~/.aws:/root/.aws h9 publish <environment>
```

## Rendering Rules

- For Jade and Stylus, anything with an underscore is skipped.

- Any files inside a folder named `node_modules` or `bower_components` are skipped.

- YAML files are added to the context (locals) available in Jade.

- Markdown files look for a Jade `_layout` file to use as a rendering context.

- You can include inline CoffeeScript and Stylus (mostly for Web Components) as shown below:

```
style(rel="stylesheet")
   include:stylus _src/styles.styl

script(type="text/javascript")
   include:coffee-script _src/index.coffee
```

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
