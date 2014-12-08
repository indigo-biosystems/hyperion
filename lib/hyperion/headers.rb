class Hyperion
  module Headers

    def post_headers(format)
      {
          'Content-Type' => content_type(format)
      }
    end

    def default_headers(type, version, format)
      {
          'Accept' => "application/vnd.indigobio-ascent.#{type}-v#{version}+#{format}"
      }
    end

    def content_type(format)
      case format
        when 'json'; 'application/json'
      end
    end

  end
end