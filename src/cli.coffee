{join} = require "path"
program = require "commander"
{call, read} = require "fairmont"

require "./index"
{run} = require "panda-9000"

# exit on ctrl-c, related signals
# https://github.com/pandastrike/haiku9/issues/88
process.on 'SIGHUP',  ()-> process.exit()
process.on 'SIGINT',  ()-> process.exit()
process.on 'SIGQUIT', ()-> process.exit()
process.on 'SIGABRT', ()-> process.exit()
process.on 'SIGTERM', ()-> process.exit()


call ->

  {version} = JSON.parse yield read join __dirname, "..", "package.json"

  program
    .version(version)

  program
    .command('serve')
    .description('run a Web server to serve your content')
    .action(-> run "serve")

  program
    .command('build')
    .description('compile the Website assets into the "target" directory')
    .action(-> run "build")

  program
    .command('publish [env]')
    .description('deploy Website assets from "target" to AWS infrastructure')
    .option("-f, --force", "force the upload of all files, ignoring cloud sync comparisons")
    .action(
      (env, options)->
        if !env
          console.error "No environment has been provided."
          console.error "Usage: h9 publish <environment>"
          process.exit 1

        run "publish", [env, options]
    )


  # Begin execution.
  program.parse(process.argv);
