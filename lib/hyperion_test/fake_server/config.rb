class Hyperion
  class FakeServer
    class Config
      # this is passed to the block to allow the caller to configure the fake server

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
  end
end
