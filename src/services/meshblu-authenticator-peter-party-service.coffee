Chance      = require 'chance'
_           = require 'lodash'
MeshbluHttp = require 'meshblu-http'
RefResolver = require 'meshblu-json-schema-resolver'
{PeterCreator, PeterPartyToItselfSubscriber, PeterPartyToPeterSubscriber} = require 'peter-party-planner'

class MeshbluAuthenticatorPeterPartyService
  constructor: ({@meshbluConfig, @redirectUri}) ->
    @chance = new Chance()
    @creator = new PeterCreator {ownerUUID: @meshbluConfig.uuid, peterPartyUUID: @meshbluConfig.uuid, @meshbluConfig}
    @partySubscriber = new PeterPartyToPeterSubscriber {peterPartyUUID: @meshbluConfig.uuid, @meshbluConfig}

  addMember: ({uuid, token}, callback) =>
    memberToken = token
    memberUuid  = uuid

    @_getRoomGroupStatusUuid (error, roomGroupStatusUuid) =>
      return callback error if error?
      @_grantMemberViewPermissionToRoomGroupStatus {memberUuid, memberToken, roomGroupStatusUuid}, (error) =>
        return callback error if error?
        @_updateMember {memberUuid, memberToken, roomGroupStatusUuid}, callback


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

  _getRoomGroupStatusUuid: (callback) =>
    meshbluHttp = new MeshbluHttp @meshbluConfig
    resolver    = new RefResolver {@meshbluConfig}

    meshbluHttp.device @meshbluConfig.uuid, (error, device) =>
      return callback @_createError({ message: "Error getting user group device", error}) if error?
      resolver.resolve device, (error, resolved) =>
        return callback @_createError({ message: "Error resolving user group $ref", error}) if error?
        roomGroupStatusUuid = _.get(resolved, 'genisys.customerDevices.roomGroupStatus.uuid')
        return callback @_createError({ message: "Error getting room group status uuid", code: 404}) if _.isEmpty(roomGroupStatusUuid)
        return callback null, roomGroupStatusUuid

  _grantMemberViewPermissionToRoomGroupStatus: ({ memberUuid, roomGroupStatusUuid }, callback) =>
    meshbluHttp = new MeshbluHttp @meshbluConfig
    resolver    = new RefResolver {@meshbluConfig}

    meshbluHttp.device @meshbluConfig.uuid, (error, device) =>
      return callback @_createError({ message: "Error getting user group device", error}) if error?
      resolver.resolve device, (error, resolved) =>
        return callback @_createError({ message: "Error resolving user group $ref", error}) if error?
        customerId = _.get(resolved, 'genisys.customerDevices.customer.uuid')

        update = {
          $addToSet:
            'meshblu.whitelists.discover.view': { uuid: memberUuid }
            'meshblu.whitelists.configure.sent': { uuid: memberUuid }
        }
        meshbluHttp.updateDangerously roomGroupStatusUuid, update, {as: customerId}, (error) =>
          return callback @_createError({message: "Error updating room group status discover whitelist", error}) if error?
          return callback()

  _updateMember: ({ memberUuid, memberToken, roomGroupStatusUuid },  callback) =>
    meshbluHttp = new MeshbluHttp _.defaults({uuid: memberUuid, token: memberToken}, @meshbluConfig)

    update = {
      $addToSet:
        'meshblu.whitelists.configure.sent':   {uuid: @meshbluConfig.uuid}
        'meshblu.whitelists.configure.update': {uuid: @meshbluConfig.uuid}
        'meshblu.whitelists.broadcast.sent':   {uuid: @meshbluConfig.uuid}
      $set:
        userGroup: @meshbluConfig.uuid
        'genisys.devices.user-group.uuid': @meshbluConfig.uuid
        'genisys.devices.room-group-status.uuid': roomGroupStatusUuid
    }

    meshbluHttp.updateDangerously memberUuid, update, (error) =>
      return callback @_createError({message: "Error updating peter's whitelists", error}) if error?
      selfSubscriber = new PeterPartyToItselfSubscriber {@meshbluConfig, peterPartyUUID: memberUuid}
      selfSubscriber.subscribe (error) =>
        return callback @_createError({message: "Error subscribing Peter to himself", error}) if error?
        @partySubscriber.subscribe memberUuid, (error) =>
          return callback @_createError({message: "Error subscribing the Party to Peter", error}) if error?
          return callback()

module.exports = MeshbluAuthenticatorPeterPartyService
