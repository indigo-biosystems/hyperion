require 'hyperion/headers'

class ResponseDescriptor
  include Hyperion::Headers

  attr_reader :type, :version, :format

  # @param type [String]
  # @param version [Integer]
  # @param format [Symbol] :json
  def initialize(type, version, format)
    @type, @version, @format = type, version, format
  end

  def to_s
    short_mimetype(self)
  end
end

