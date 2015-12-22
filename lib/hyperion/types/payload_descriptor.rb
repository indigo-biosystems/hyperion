class PayloadDescriptor
  # describes the payload sent in POST/PUT/PATCH

  attr_reader :format

  def initialize(format)
    @format = format
  end

  def as_json(*_args)
    {
        'format' => format.to_s,
    }
  end
end
