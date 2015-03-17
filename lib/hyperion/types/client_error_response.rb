require 'hyperion/aux/util'
require 'hyperion/types/client_error_code'
require 'hyperion/types/client_error_detail'

class ClientErrorResponse
  # The structure expected in a 400 response.

  attr_reader :code     # [ClientErrorCode]  The type of error. At least one of the ErrorInfos should have the same code.
  attr_reader :message  # [String]                     An error message that can be presented to the user
  attr_reader :errors   # [Array<ErrorInfo>]           Structured information with error specifics
  attr_reader :body     # [String, nil]                An optional body to return; may be an application-specific description of the error.

  def initialize(message, errors, code=nil, body=nil)
    Hyperion::Util.guard_param(message, 'a message string', String)
    Hyperion::Util.guard_param(errors, 'an array of errors', &method(:error_array?))
    code ||= errors.first.try(:code) || ClientErrorCode::UNKNOWN
    Hyperion::Util.guard_param(code, 'a code') { ClientErrorCode.values.include?(code) }

    @message = message
    @code = code
    @errors = errors
    @body = body
  end

  def as_json(*_args)
    {
        'message' => message,
        'code' => code,
        'errors' => errors.map(&:as_json),
        'body' => body
    }
  end

  def self.from_attrs(attrs)
    Hyperion::Util.nil_if_error do
      message = attrs['message']
      code = attrs['code']
      body = attrs['body']
      return nil if message.blank?
      errors = (attrs['errors'] || []).map(&ClientErrorDetail.method(:from_attrs))
      self.new(message, errors, code, body)
    end
  end

  private

  def error_array?(xs)
    xs.is_a?(Array) && xs.all?{|x| x.is_a?(ClientErrorDetail)}
  end
end
