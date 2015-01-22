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
  def initialize(method, uri, response_descriptor, payload_descriptor=nil)
    @method = method
    @uri = URI(uri)
    @response_descriptor = response_descriptor
    @payload_descriptor = payload_descriptor
  end
end

class HyperionResult < ImmutableStruct.new(:status, :code, :body)
  module Status
    include Enum
    TIMED_OUT = 'timed_out'
    NO_RESPONSE = 'no_response'
    CHECK_CODE = 'check_code'
    SUCCESS = 'success'
  end
end
