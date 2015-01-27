require 'uri'
require 'hyperion/enum'

PayloadDescriptor = ImmutableStruct.new(:format)

class ResponseDescriptor
  attr_reader :type, :version, :format

  # @param type [String]
  # @param version [Integer]
  # @param format [Symbol] :json
  def initialize(type, version, format)
    @type, @version, @format = type, version, format
  end
end

class PayloadDescriptor
  attr_reader :format

  def initialize(format)
    @format = format
  end
end

class RestRoute
  attr_reader :method, :uri, :response_descriptor, :payload_descriptor

  # @param method [Symbol] the HTTP method
  # @param uri [String, URI]
  # @param response_descriptor [ResponseDescriptor]
  # @param payload_descriptor [PayloadDescriptor]
  def initialize(method, uri, response_descriptor, payload_descriptor=nil)
    @method = method
    @uri = URI(uri)
    @response_descriptor = response_descriptor
    @payload_descriptor = payload_descriptor
  end
end

class HyperionResult
  attr_reader :status, :code, :body

  module Status
    include Enum
    TIMED_OUT = 'timed_out'
    NO_RESPONSE = 'no_response'
    CHECK_CODE = 'check_code'
    SUCCESS = 'success'
  end

  # @param status [HyperionResult::Status]
  # @param code [Integer] the HTTP response code
  # @param body [Object, Hash<String,Object>] the deserialized response body.
  #   The type is determined by the content-type.
  #   JSON is deserialized to a Hash<String, Object>
  def initialize(status, code=nil, body=nil)
    @status, @code, @body = status, code, body
  end
end
