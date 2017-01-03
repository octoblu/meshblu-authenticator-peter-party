async       = require 'async'
_           = require 'lodash'
MeshbluHttp = require 'meshblu-http'

class HealthcheckService
  constructor: ({meshbluConfig}) ->
    throw new Error 'Missing required parameter: meshbluConfig' unless meshbluConfig?
    @meshblu = new MeshbluHttp meshbluConfig

  healthcheck: (callback) =>
    async.parallel meshbluHttp: @checkMeshbluHttp, (error, components) =>
      return callback error if error?
      return callback null, {
        healthy: _.every components, 'healthy'
        components: components
      }

  checkMeshbluHttp: (callback) =>
    @meshblu.healthcheck (error, healthy, code) =>
      return callback null, {
        healthy: healthy
        code:    code
        error:   error
      }

module.exports = HealthcheckService
