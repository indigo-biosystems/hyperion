require 'hyperion-test/test_framework_hooks'

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
            rule = server.find_matching_rule(mimic_route, request)
            rule.handler.call(server.make_req_obj(request.body.read, request.env['CONTENT_TYPE']))
          end
        end
      end
      @mimic_running = true
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
        when 'HOST'; 'HTTP_HOST'
        when 'USER_AGENT'; 'HTTP_USER_AGENT'
        else; cased_header
      end
    end

    class Setup
      include Hyperion::Headers

      def rules
        @rules ||= []
      end

      # allow(route)
      # allow(method, path, headers={})
      def allow(*args, &handler)
        if args.size == 1 && args.first.is_a?(RestRoute)
          route = args.first
          rules << Rule.new(MimicRoute.new(route.method, route.uri.path), route_headers(route), handler)
        else
          method, path, headers = args
          headers ||= {}
          rules << Rule.new(MimicRoute.new(method, path), headers, handler)
        end
      end
    end

    MimicRoute = ImmutableStruct.new(:method, :path)
    Rule = ImmutableStruct.new(:mimic_route, :headers, :handler)
    Request = ImmutableStruct.new(:body)
  end
end

class Hash
  def subhash?(hash)
    each_pair.all?{|k, v| hash[k] == v}
  end
end
