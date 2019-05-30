# Haiku9

Haiku9 (H9 for short) is a static site publisher. H9 supports:

- Syncing Web assets with an S3 bucket
- Configuring that bucket as a website
- Optionally fronting that bucket with a CloudFront distribution to support edge caching and/or TLS termination.

H9 provides CLI and programmatic interfaces, though most of the configuration is handled with your `h9.yaml` file.

## Installation

### Local

```shell
npm install -g haiku9
```

## Configuration

### AWS Profile
H9 uses your AWS access to perform actions on your behalf.  Your environment needs access to AWS credentials that can be reached by the [`SharedIniFileCredentials` method](https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/SharedIniFileCredentials.html)

From that reference:
> defaulting to `~/.aws/credentials` or defined by the `AWS_SHARED_CREDENTIALS_FILE` environment variable

Within that file, you can assign credentials to multiple "profiles" for easy access.  H9 can accept that profile name as a command-line argument
```
h9 publish production -p "panda"
```

### H9 File

At the root of your site, create a `h9.yaml` file. Here is an example for publishing to a hypothetical https://haiku9.pandastrike.com

```yaml
# The directory Haiku9 will copy into an S3 bucket.  The local directory is
# authoritative, so files will be added or deleted from your bucket to make
# it match. Haiku9 also uses MD5 hashes to make sure existing bucket files
# are current.
source: build

# The root domain for your site.
domain: pandastrike.com

# The AWS region you would like to use for your S3 bucket that serves your site
region: us-west-1

# The default path when navigating to "/", as well as the page to serve if
# a requested path does not exist.
site:
  index: index
  error: 404

# If you a publishing content to CDN that will be accessed through CORS, you can set your CORS settings here.  `wildstyle` is the permissive "*"
cors: wildstyle


# Haiku9 uses environments to organize your a project's configuration into
# sections while maintaining access to common configuration.  Each environment
# is named as the keys in the dictionary below.
environments:

  # The staging environment has a hostname, but no cache configuration, so it
  # will serve directly from the S3 bucket without TLS termination.
  staging:
    hostnames:
      - staging-haiku

  # The production environment has a different hostname setting, as well as
  # configuration for the CloudFront distribution.
  production:
    hostnames:
      - haiku
    cache:
      expires: 1800 # 30 minutes
      ssl: true
      priceClass: 100
```


## Publishing


To publish your compiled site to AWS, first confirm that your AWS credentials are defined in `~/.aws/credentials`:

  [default]
  aws_access_key_id=AKIAIOSFODNN7EXAMPLE
  aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

Next, publish to AWS:

```shell
h9 publish <environment>
```

And in a few minutes you will have a new website.

If you would like to tear it down.

```shell
h9 delete <environment>
```

And it will be gone just as easily.
