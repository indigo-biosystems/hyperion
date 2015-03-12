require 'hyperion/formats'

class Hyperion
  module Headers

    def route_headers(route)
      headers = {}
      rd = route.response_descriptor
      pd = route.payload_descriptor
      headers['Expect'] = 'x' # this overrides default libcurl behavior.
                              # see http://devblog.songkick.com/2012/11/27/a-second-here-a-second-there/
                              # the value has to be non-empty or else it's ignored
      if rd
        headers['Accept'] = "application/vnd.indigobio-ascent.#{short_mimetype(rd)}"
      end
      if pd
        headers['Content-Type'] = content_type_for(pd.format)
      end
      headers
    end

    def short_mimetype(response_descriptor)
      x = response_descriptor
      "#{x.type}-v#{x.version}+#{x.format}"
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
