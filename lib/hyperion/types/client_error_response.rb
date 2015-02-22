class ClientErrorResponse
  attr_reader :message  # [String]            An error message that can be presented to the user
  attr_reader :errors   # [Array<ErrorInfo>]  Structured information with error specifics

  def initialize(message, *errors)
    @message = message
    @errors = errors || []
  end

  def as_json(*_args)
    {'message' => message, 'errors' => errors.map(&:as_json)}
  end

  def self.from_attrs(attrs)
    message = attrs['message']
    errors = attrs['errors'].map(&ErrorInfo.method(:from_attrs))
    self.new(message, errors)
  end
end
