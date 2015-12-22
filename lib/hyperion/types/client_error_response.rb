require 'hyperion/aux/util'
require 'hyperion/types/client_error_code'
require 'hyperion/types/client_error_detail'

class ClientErrorResponse
  # The structure expected in a 400 response.

  attr_reader :code     # [ClientErrorCode]            The type of error. At least one of the ClientErrorDetails should have the same code.
  attr_reader :message  # [String]                     An error message that can be presented to the user
  attr_reader :errors   # [Array<ClientErrorDetail>]   Structured information with error specifics
  attr_reader :content  # [String, nil]                Optional content to return; may be an application-specific description of the error.

  def initialize(message, errors, code=nil, content=nil)
    Hyperion::Util.guard_param(message, 'a message string', String)
    Hyperion::Util.guard_param(errors, 'an array of errors', &method(:error_array?))
    code = ClientErrorCode.from(code || errors.first.try(:code) || ClientErrorCode::UNKNOWN)
    Hyperion::Util.guard_param(code, 'a code') { ClientErrorCode.values.include?(code) }

    @message = message
    @code = code
    @errors = errors
    @content = content
  end

  def as_json(*_args)
    {
        'message' => message,
        'code' => code.value,
        'errors' => errors.map(&:as_json),
        'content' => content
    }
  end

  def self.from_attrs(attrs)
    Hyperion::Util.nil_if_error do
      message = attrs['message']
      return nil if message.blank?
      content = attrs['content']
      code = code || ClientErrorCode.from(attrs['code'])
      errors = (attrs['errors'] || []).map(&ClientErrorDetail.method(:from_attrs))
      self.new(message, errors, code, content)
    end
  end

  private

  def error_array?(xs)
    xs.is_a?(Array) && xs.all?{|x| x.is_a?(ClientErrorDetail)}
  end
end
