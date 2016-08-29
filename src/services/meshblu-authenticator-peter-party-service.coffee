Chance      = require 'chance'
MeshbluHttp = require 'meshblu-http'
{PeterCreator, PeterPartyToItselfSubscriber, PeterPartyToPeterSubscriber} = require 'peter-party-planner'

class MeshbluAuthenticatorPeterPartyService
  constructor: ({@meshbluConfig, @redirectUri}) ->
    @chance = new Chance()
    @creator = new PeterCreator {ownerUUID: @meshbluConfig.uuid, peterPartyUUID: @meshbluConfig.uuid, @meshbluConfig}
    @partySubscriber = new PeterPartyToPeterSubscriber {peterPartyUUID: @meshbluConfig.uuid, @meshbluConfig}

  register: (callback) =>
    @creator.create name: @chance.name({middle_initial: true, prefix: true, suffix: true}), (error, peter) =>
      return callback @_createError({message: "Error creating peter", error}) if error?
      selfSubscriber = new PeterPartyToItselfSubscriber {@meshbluConfig, peterPartyUUID: peter.uuid}
      selfSubscriber.subscribe =>
        return callback @_createError({message: "Error subscribing Peter to himself", error}) if error?
        @partySubscriber.subscribe peter.uuid, (error) =>
          return callback @_createError({message: "Error subscribing the Party to Peter", error}) if error?
          return callback null, peter

  _createError: ({code, message, error}) =>

    message = "#{message}: (#{error.message})" if error?
    code = error.code unless code?

    error = new Error message
    error.code = code if code?
    return error


module.exports = MeshbluAuthenticatorPeterPartyService
