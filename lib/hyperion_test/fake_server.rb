require 'hyperion_test/test_framework_hooks'
require 'hyperion/aux/hash_ext'
require 'hyperion_test/fake_server/dispatcher'
require 'hyperion_test/fake_server/types'
require 'hyperion_test/fake_server/config'

class Hyperion
  class FakeServer
    # Runs a Mimic server configured per the specified routing rules.
    # Restarts the server when the rules change.
    # The server must be restarted because it runs in a forked process
    # and it is easier to kill it than try to communicate with it.

    attr_accessor :port, :rules

    def initialize(port)
      @port = port
      @rules = []
    end

    def configure(&configure_routes)
      config = Config.new
      configure_routes.call(config)
      rules.concat(config.rules)
      restart_server
    end

    def teardown
      rules.clear
      @mimic_running = true
      Mimic.cleanup!
    end

    def restart_server
      server = self
      dispatcher = Dispatcher.new(rules)
      Mimic.cleanup! if @mimic_running
      Mimic.mimic(port: @port) do
        # this block executes in a strange context, which is why we
        # have to close over server and dispatcher
        server.rules.map(&:mimic_route).uniq.each do |mimic_route|
          # register the route handlers. this is basically Sinatra.
          send(mimic_route.method, mimic_route.path) do
            dispatcher.dispatch(mimic_route, request)
          end
        end
      end
      @mimic_running = true
    end
  end
end
