_             = require 'lodash'
OctobluRaven  = require 'octoblu-raven'
MeshbluConfig = require 'meshblu-config'
Server        = require './src/server'

class Command
  constructor: ->
    @serverOptions =
      meshbluConfig : new MeshbluConfig().toJSON()
      port          : process.env.PORT || 80
      disableLogging: process.env.DISABLE_LOGGING == "true"
      octobluRaven  : new OctobluRaven()

  handleErrors: =>
    @serverOptions.octobluRaven.patchGlobal()

  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    server = new Server @serverOptions
    server.run (error) =>
      return @panic error if error?

      {address,port} = server.address()
      console.log "MeshbluAuthenticatorPeterPartyService listening on port: #{port}"

    process.on 'SIGTERM', =>
      console.log 'SIGTERM caught, exiting'
      server.stop =>
        process.exit 0

command = new Command()
command.handleErrors()
command.run()