MeshbluAuth                              = require 'express-meshblu-auth'
MeshbluAuthenticatorPeterPartyController = require './controllers/meshblu-authenticator-peter-party-controller'
HealthcheckController                    = require './controllers/healthcheck-controller'

class Router
  constructor: ({healthcheckService, meshbluConfig, meshbluAuthenticatorPeterPartyService}) ->
    @healthcheckController = new HealthcheckController {healthcheckService}
    @meshbluAuthenticatorPeterPartyController = new MeshbluAuthenticatorPeterPartyController {meshbluAuthenticatorPeterPartyService}
    @meshbluAuth = new MeshbluAuth meshbluConfig

  route: (app) =>
    app.get '/proofoflife', @healthcheckController.get
    app.use @meshbluAuth.auth()
    app.post '/register', @meshbluAuthenticatorPeterPartyController.register
    app.post '/members', @meshbluAuth.gateway(), @meshbluAuthenticatorPeterPartyController.addMember

module.exports = Router
