help = """
  Usage: h9 [command]
  Options:
    -V, --version  output the version number
    -h, --help     output usage information
  Commands:
    publish [environment]     Publish static site assets to AWS infrastructure,
                                for a given environment
      -p --profile            Name of AWS profile to use, as named in your AWS
                                credentials file. Defaults to 'default'
    delete [environment]      Delete static site assets from AWS infrastructure,
                                for a given environment
  """
