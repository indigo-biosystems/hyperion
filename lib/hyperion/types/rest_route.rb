require 'hyperion/types/hyperion_uri'

class RestRoute
  attr_reader :method, :uri, :response_descriptor, :payload_descriptor

  # @param method [Symbol] the HTTP method
  # @param uri [String, URI]
  # @param response_descriptor [ResponseDescriptor]
  # @param payload_descriptor [PayloadDescriptor]
  def initialize(method, uri, response_descriptor=nil, payload_descriptor=nil)
    @method = method
    @uri = HyperionUri.new(uri)
    @response_descriptor = response_descriptor
    @payload_descriptor = payload_descriptor
  end

  def to_s
    "#{method.to_s.upcase} #{uri}"
  end
end
