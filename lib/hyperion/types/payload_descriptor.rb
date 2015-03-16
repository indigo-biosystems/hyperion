class PayloadDescriptor
  # describes the payload sent in POST/PUT/PATCH

  attr_reader :format

  def initialize(format)
    @format = format
  end
end
