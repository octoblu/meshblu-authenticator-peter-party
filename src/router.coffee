MeshbluAuthenticatorPeterPartyController = require './controllers/meshblu-authenticator-peter-party-controller'

class Router
  constructor: ({@meshbluAuthenticatorPeterPartyService}) ->

  route: (app) =>
    meshbluAuthenticatorPeterPartyController = new MeshbluAuthenticatorPeterPartyController {@meshbluAuthenticatorPeterPartyService}

    app.post '/register', meshbluAuthenticatorPeterPartyController.register

module.exports = Router
