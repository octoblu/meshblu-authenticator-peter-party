enableDestroy      = require 'server-destroy'
expressOctoblu     = require 'express-octoblu'

Router             = require './router'
HealthcheckService = require './services/healthcheck-service'
MeshbluAuthenticatorPeterPartyService = require './services/meshblu-authenticator-peter-party-service'

class Server
  constructor: ({@disableLogging, @port, @meshbluConfig, @redirectUri})->
    @healthcheckService = new HealthcheckService {@meshbluConfig}
    @meshbluAuthenticatorPeterPartyService = new MeshbluAuthenticatorPeterPartyService {@meshbluConfig, @redirectUri}

  address: =>
    @server.address()

  run: (callback) =>
    app = expressOctoblu()
    router = new Router {@healthcheckService, @meshbluConfig, @meshbluAuthenticatorPeterPartyService, @meshbluAuth}
    router.route app

    @server = app.listen @port, callback
    enableDestroy @server

  stop: (callback) =>
    @server.close callback

  destroy: =>
    @server.destroy()

module.exports = Server
