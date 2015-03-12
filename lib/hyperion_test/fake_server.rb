require 'hyperion_test/test_framework_hooks'

# TODO: this class is doing too much
class Hyperion
  class FakeServer
    include Hyperion::Headers
    include Hyperion::Formats

    attr_accessor :port, :rules

    def initialize(port)
      @port = port
      @rules = []
    end

    def configure(&setup_routes)
      setup = Setup.new
      setup_routes.call(setup)
      rules.concat(setup.rules)
      restart_server
    end

    def teardown
      rules.clear
      @mimic_running = true
      Mimic.cleanup!
    end

    def restart_server
      server = self
      Mimic.cleanup! if @mimic_running
      Mimic.mimic(port: @port) do
        server.rules.map(&:mimic_route).uniq.each do |mimic_route|
          send(mimic_route.method, mimic_route.path) do
            server.invoke_handler(mimic_route, request)
          end
        end
      end
      @mimic_running = true
    end

    def invoke_handler(mimic_route, request)
      rule = find_matching_rule(mimic_route, request)
      unless rule
        return [404, {}, "Not stubbed: #{mimic_route.inspect} #{request.env}"]
      end
      response = rule.handler.call(make_req_obj(request.body.read, request.env['CONTENT_TYPE']))
      if rack_response?(response)
        code, headers, body = *response
        [code, headers, write(body, :json)]
      else
        if rule.rest_route
          rd = rule.rest_route.response_descriptor
          [200, {'Content-Type' => content_type_for(rd)}, write(response, rd)]
        else
          [500, {}, "An 'allow' block must return a rack-style response if it was not passed a RestRoute"]
        end
      end
    end

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
      Hash[headers.map { |k, v| [sinatra_header(k), v] }]
    end

    def sinatra_header(header)
      cased_header = header.upcase.gsub('-', '_')
      case cased_header
        when 'ACCEPT'; 'HTTP_ACCEPT'
        when 'EXPECT'; 'HTTP_EXPECT'
        when 'HOST'; 'HTTP_HOST'
        when 'USER_AGENT'; 'HTTP_USER_AGENT'
        else; cased_header
      end
    end

    class Setup
      include Hyperion::Headers
      include Hyperion::Logger

      def rules
        @rules ||= []
      end

      # allow(route)
      # allow(method, path, headers={})
      def allow(*args, &handler)
        rule = allowed_rule(args, handler)
        rules << rule
        log_stub(rule)
      end

      private

      def allowed_rule(args, handler)
        if args.size == 1 && args.first.is_a?(RestRoute)
          route = args.first
          Rule.new(MimicRoute.new(route.method, route.uri.path), route_headers(route), handler, route)
        else
          # TODO: deprecate this
          method, path, headers = args
          headers ||= {}
          Rule.new(MimicRoute.new(method, path), headers, handler, nil)
        end
      end
    end

    MimicRoute = ImmutableStruct.new(:method, :path)
    Rule = ImmutableStruct.new(:mimic_route, :headers, :handler, :rest_route)
    Request = ImmutableStruct.new(:body)
  end
end

class Hash
  def subhash?(hash)
    each_pair.all?{|k, v| hash[k] == v}
  end
end
