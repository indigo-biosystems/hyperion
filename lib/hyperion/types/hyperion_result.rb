require 'active_support/inflector'
require 'abstractivator/enum'

class HyperionResult
  attr_reader :route, :status, :code, :body

  define_enum :Status,
              :success,
              :timed_out,
              :no_response,
              :bad_route,        # 404 (route not implemented)
              :client_error,     # 400
              :server_error,     # 500
              :check_code        # everything else


  # @param status [HyperionResult::Status]
  # @param code [Integer] the HTTP response code
  # @param body [Object, Hash<String,Object>] the deserialized response body.
  #   The type is determined by the content-type.
  #   JSON is deserialized to a Hash<String, Object>
  def initialize(route, status, code=nil, body=nil)
    @route, @status, @code, @body = route, status, code, body
  end

  def to_s
    if status == Status::CHECK_CODE
      "HTTP #{code}: #{route.to_s}"
    elsif status == Status::BAD_ROUTE
      "#{status.to_s.humanize} (#{code}): #{route.to_s}"
    else
      "#{status.to_s.humanize}: #{route.to_s}"
    end
  end
end
