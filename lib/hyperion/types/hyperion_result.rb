require 'active_support/inflector'

class HyperionResult
  attr_reader :route, :status, :code, :body

  # @param route [RestRoute]
  # @param status [HyperionStatus]
  # @param code [Integer] the HTTP response code
  # @param body [Object, Hash<String,Object>] the deserialized response body.
  #   The type is determined by the content-type.
  #   JSON is deserialized to a Hash<String, Object>
  def initialize(route, status, code=nil, body=nil)
    @route, @status, @code, @body = route, status, code, body
  end

  def as_json(*_args)
    {
        'route' => route.as_json(*_args),
        'status' => status.value,
        'code' => code,
        'body' => body.as_json(*_args),
    }
  end

  def to_s
    if status == HyperionStatus::CHECK_CODE
      "HTTP #{code}: #{route.to_s}"
    elsif status == HyperionStatus::BAD_ROUTE
      "#{status.value.to_s.humanize} (#{code}): #{route.to_s}"
    else
      "#{status.value.to_s.humanize}: #{route.to_s}"
    end
  end
end
