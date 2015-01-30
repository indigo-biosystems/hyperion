class Hyperion
  module Headers

    def route_headers(route)
      headers = {}
      rd = route.response_descriptor
      pd = route.payload_descriptor
      if rd
        headers['Accept'] = "application/vnd.indigobio-ascent.#{rd.type}-v#{rd.version}+#{rd.format}"
      end
      if pd
        headers['Content-Type'] = content_type_for(pd.format)
      end
      headers
    end

    ContentTypes = [[:json, 'application/json'],
                    [:protobuf, 'application/x-protobuf']]

    def content_type_for(format)
      format = Hyperion::Formats.get_from(format)
      ct = ContentTypes.detect{|x| x.first == format}
      ct ? ct.last : 'application/octet-stream'
    end

    def format_for(content_type)
      ct = ContentTypes.detect{|x| x.last == content_type}
      raise "Unsupported content type: #{content_type}" unless ct
      ct.first
    end
  end
end
