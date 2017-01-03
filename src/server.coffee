cors               = require 'cors'
morgan             = require 'morgan'
express            = require 'express'
bodyParser         = require 'body-parser'
OctobluRaven       = require 'octoblu-raven'
enableDestroy      = require 'server-destroy'
sendError          = require 'express-send-error'
packageVersion     = require 'express-package-version'
meshbluHealthcheck = require 'express-meshblu-healthcheck'

Router             = require './router'
HealthcheckService = require './services/healthcheck-service'
MeshbluAuthenticatorPeterPartyService = require './services/meshblu-authenticator-peter-party-service'

class Server
  constructor: ({@disableLogging, @port, @meshbluConfig, @redirectUri, @octobluRaven})->
    @octobluRaven ?= new OctobluRaven()
    @healthcheckService = new HealthcheckService {@meshbluConfig}
    @meshbluAuthenticatorPeterPartyService = new MeshbluAuthenticatorPeterPartyService {@meshbluConfig, @redirectUri}

  address: =>
    @server.address()

  run: (callback) =>
    app = express()
    app.use @octobluRaven.express().handleErrors()
    app.use sendError()
    app.use meshbluHealthcheck()
    app.use packageVersion()
    app.use morgan 'dev', immediate: false unless @disableLogging
    app.use cors()
    app.use bodyParser.urlencoded limit: '1mb', extended : true
    app.use bodyParser.json limit : '1mb'

    app.options '*', cors()

    router = new Router {@healthcheckService, @meshbluConfig, @meshbluAuthenticatorPeterPartyService, @meshbluAuth}

    router.route app

    @server = app.listen @port, callback
    enableDestroy @server

  stop: (callback) =>
    @server.close callback

  destroy: =>
    @server.destroy()

module.exports = Server
