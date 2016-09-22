require 'hyperion_test/test_framework_hooks'
require 'hyperion/aux/hash_ext'
require 'hyperion/headers'
require 'hyperion/formats'
require 'hyperion_test/fake_server/types'
require 'hyperion_test/fake_server/config'
require 'hyperion_test/kim'
require 'hyperion_test/kim/matchers'
require 'hyperion_test/server_pool'

class Hyperion
  class FakeServer
    # Runs a Kim server configured per the specified routing rules.
    include Kim::Matchers
    include Headers
    include Formats

    attr_accessor :port

    def initialize(port)
      @port = port
      @kim = Kim.new(port: port)
      @kim.start
    end

    def configure(&configure_routes)
      config = Config.new
      configure_routes.call(config)
      config.rules.each do |rule|
        matcher = Kim::Matcher.and(verb(rule.verb),
                                   res(rule.path),
                                   req_headers(rule.headers))
        handler = wrap(rule.handler, rule.rest_route)
        @kim.add_handler(matcher, &handler)
      end
    end

    def clear_routes
      @kim.clear_handlers
    end

    def teardown
      @kim.stop
    end

    private

    # Make it easier to write handlers by massaging input and output
    def wrap(handler, rest_route)
      proc do |req|
        massage_request!(req)
        resp = handler.call(req)
        massage_response(resp, rest_route)
      end
    end

    def massage_request!(req)
      if req.body && !req.body.empty?
        req.body = read(req.body, :json)
      end
    end

    def massage_response(resp, rest_route)
      if rack_response?(resp)
        code, headers, body = resp
        unless body.is_a?(String)
          body = write(body, :json)
        end
        [code, headers, body]
      else
        if rest_route
          rd = rest_route.response_descriptor
          content_type = content_type_for(rd)
          format = rd
        else
          content_type = 'application/json'
          format = :json
        end
        ['200', {'Content-Type' => content_type}, write(resp, format)]
      end
    end

    def rack_response?(resp)
      resp.is_a?(Array) && resp.size == 3
    end
  end
end
