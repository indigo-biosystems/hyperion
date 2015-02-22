class PayloadDescriptor
  attr_reader :format

  # Contract ValidEnum[Hyperion::Formats::Known] => Any
  def initialize(format)
    @format = format
  end
end
