require 'hyperion/headers'

class Hyperion
  class FakeServer
    class Dispatcher
      include Hyperion::Formats
      include Hyperion::Headers

      def initialize(rules)
        @rules = rules
      end

      def dispatch(mimic_route, request)
        rule = find_matching_rule(mimic_route, request)
        rule or return [404, {}, "Not stubbed: #{mimic_route.inspect} #{request.env}"]
        request = make_req_obj(request.body.read, request.env['CONTENT_TYPE'])
        response = rule.handler.call(request)
        if rack_response?(response)
          code, headers, body = *response
          [code, headers, write(body, :json)]
        else
          if rule.rest_route
            rd = rule.rest_route.response_descriptor
            [200, {'Content-Type' => content_type_for(rd)}, write(response, rd)]
          else
            # better to return a 500 than raise an error, since we're executing in the forked server.
            [500, {}, "An 'allow' block must return a rack-style response if it was not passed a RestRoute"]
          end
        end
      end

      private

      attr_reader :rules

      def rack_response?(x)
        x.is_a?(Array) && x.size == 3 && x.first.is_a?(Integer) && x.drop(1).any?{|y| !y.is_a?(Integer)}
      end

      def find_matching_rule(mimic_route, request)
        matching_rules = rules.select{|rule| rule.mimic_route == mimic_route}
        matching_rules.reverse.detect{|rule| headers_match?(rule.headers, request.env)}
        # reverse so that if there are duplicates, the last one wins
      end

      def make_req_obj(raw_body, content_type)
        body = raw_body.empty? ? '' : read(raw_body, format_for(content_type))
        Request.new(body)
      end

      def headers_match?(rule_headers, actual_headers)
        sinatrize_headers(rule_headers).subhash?(actual_headers)
      end

      def sinatrize_headers(headers)
        headers.map{|k, v| [sinatra_header(k), v]}.to_h
      end

      def sinatra_header(header)
        # TODO: there should be a function in Sinatra that does this already
        cased_header = header.upcase.gsub('-', '_')
        case cased_header
          when 'ACCEPT'; 'HTTP_ACCEPT'
          when 'EXPECT'; 'HTTP_EXPECT'
          when 'HOST'; 'HTTP_HOST'
          when 'USER_AGENT'; 'HTTP_USER_AGENT'
          else; cased_header
        end
      end
    end
  end
end
