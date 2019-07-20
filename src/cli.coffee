import {join} from "path"
import program from "commander"
import {read} from "panda-quill"
import h9 from "./index"
import Help from "./help"

do ->

  {version} = JSON.parse await read join __dirname, "..", "..",
    "..", "package.json"

  program
    .version version

  program
    .command "publish [environment]"
    .option '-p, --profile [profile]', 'Name of AWS profile to use'
    .description "Publish static site assets to AWS infrastructure,
      for a given environment"
    .action (environment, options) ->
      if environment?
        try
          await h9.publish environment, options
        catch e
          console.error "publish failed"
          console.error e.stack
      else
        console.error "No environment has been provided."
        console.error "Usage: h9 publish <environment>"
        process.exit 1

  program
    .command "delete [environment]"
    .option '-p, --profile [profile]', 'Name of AWS profile to use'
    .description "Delete static site assets from AWS infrastructure,
      for a given environment"
    .action (environment, options) ->
      if environment?
        try
          h9.teardown environment, options
        catch e
          console.error "teardown failed"
          console.error e.stack
      else
        console.error "No environment has been provided."
        console.error "Usage: h9 delete <environment>"
        process.exit 1

  program.help = Help

  # Begin execution.
  program.parse process.argv
