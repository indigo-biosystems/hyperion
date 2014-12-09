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

    def content_type_for(format)
      case format
        when :json; 'application/json'
        else; raise "Unsupported format: #{format}"
      end
    end

    def format_for(content_type)
      case content_type
        when 'application/json'; :json
        else; raise "Unsupported content type: #{content_type}"
      end
    end

  end
end