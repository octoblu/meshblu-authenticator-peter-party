class MeshbluAuthenticatorPeterPartyController
  constructor: ({@meshbluAuthenticatorPeterPartyService}) ->

  register: (req, res) =>
    @meshbluAuthenticatorPeterPartyService.register (error, peter) =>
      return res.sendError(error) if error?
      res.status(201).send peter

module.exports = MeshbluAuthenticatorPeterPartyController
