MeshbluAuth = require 'express-meshblu-auth'
MeshbluAuthenticatorPeterPartyController = require './controllers/meshblu-authenticator-peter-party-controller'

class Router
  constructor: ({meshbluConfig, meshbluAuthenticatorPeterPartyService}) ->
    @meshbluAuthenticatorPeterPartyController = new MeshbluAuthenticatorPeterPartyController {meshbluAuthenticatorPeterPartyService}
    @meshbluAuth = new MeshbluAuth meshbluConfig

  route: (app) =>
    app.post '/register', meshbluAuthenticatorPeterPartyController.register
    app.post '/members', @meshbluAuth.gateway(), enticatorPeterPartyController.addMember

module.exports = Router
