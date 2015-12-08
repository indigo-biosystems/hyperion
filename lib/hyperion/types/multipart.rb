Multipart = Struct.new(:body) do
  def self.format
    :multipart
  end

  def self.content_type
    'multipart/form-data'
  end
end