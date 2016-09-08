class MeshbluAuthenticatorPeterPartyController
  constructor: ({@meshbluAuthenticatorPeterPartyService}) ->

  addMember: (req, res) =>
    {uuid, token} = req.meshbluAuth

    @meshbluAuthenticatorPeterPartyService.addMember {uuid, token}, (error) =>
      return res.sendError(error) if error?
      res.status(201).end()

  register: (req, res) =>
    @meshbluAuthenticatorPeterPartyService.register (error, peter) =>
      return res.sendError(error) if error?
      res.status(201).send peter

module.exports = MeshbluAuthenticatorPeterPartyController
