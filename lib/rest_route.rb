require 'uri'

class RestRoute
  attr_reader :method, :uri, :response_params

  def initialize(method, uri, response_params)
    @method = method
    @uri = uri.is_a?(String) ? URI(uri) : uri
    @response_params = response_params
  end
end
