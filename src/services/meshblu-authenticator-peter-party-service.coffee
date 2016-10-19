Chance      = require 'chance'
MeshbluHttp = require 'meshblu-http'
_           = require 'lodash'
{PeterCreator, PeterPartyToItselfSubscriber, PeterPartyToPeterSubscriber} = require 'peter-party-planner'

class MeshbluAuthenticatorPeterPartyService
  constructor: ({@meshbluConfig, @redirectUri}) ->
    @chance = new Chance()
    @creator = new PeterCreator {ownerUUID: @meshbluConfig.uuid, peterPartyUUID: @meshbluConfig.uuid, @meshbluConfig}
    @partySubscriber = new PeterPartyToPeterSubscriber {peterPartyUUID: @meshbluConfig.uuid, @meshbluConfig}

  addMember: ({uuid, token}, callback) =>
    meshbluHttp = new MeshbluHttp _.defaults({uuid, token}, @meshbluConfig)

    update = {
      $addToSet:
        'meshblu.whitelists.configure.sent':   {uuid: @meshbluConfig.uuid}
        'meshblu.whitelists.configure.update': {uuid: @meshbluConfig.uuid}
        'meshblu.whitelists.broadcast.sent':   {uuid: @meshbluConfig.uuid}
    }

    meshbluHttp.updateDangerously uuid, update, (error) =>
      return callback @_createError({message: "Error updating peter's whitelists", error}) if error?
      selfSubscriber = new PeterPartyToItselfSubscriber {@meshbluConfig, peterPartyUUID: uuid}
      selfSubscriber.subscribe (error) =>
        return callback @_createError({message: "Error subscribing Peter to himself", error}) if error?
        @partySubscriber.subscribe uuid, (error) =>
          return callback @_createError({message: "Error subscribing the Party to Peter", error}) if error?
          return callback()

  register: (callback) =>
    @creator.create name: @chance.name({middle_initial: true, prefix: true, suffix: true}), (error, peter) =>
      return callback @_createError({message: "Error creating peter", error}) if error?
      selfSubscriber = new PeterPartyToItselfSubscriber {@meshbluConfig, peterPartyUUID: peter.uuid}
      selfSubscriber.subscribe (error) =>
        return callback @_createError({message: "Error subscribing Peter to himself", error}) if error?
        @partySubscriber.subscribe peter.uuid, (error) =>
          return callback @_createError({message: "Error subscribing the Party to Peter", error}) if error?
          return callback null, _.defaults peter, resolveSrv: true

  _createError: ({code, message, error}) =>

    message = "#{message}: (#{error.message})" if error?
    code = error.code unless code?

    error = new Error message
    error.code = code if code?
    return error


module.exports = MeshbluAuthenticatorPeterPartyService
