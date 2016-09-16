require 'immutable_struct'
require 'hyperion/headers'
require 'hyperion/formats'
require 'uri'
require 'hyperion_test/fake_server'

class Hyperion
  class << self
    # Maintains a collection of fake servers, one for each base_uri.
    # Manages rspec integration for automatic teardown after each test.

    include Formats
    include Headers
    include TestFrameworkHooks
    include Logger

    # Configure routes on the server for the given base_uri
    def fake(base_uri, &routes)
      base_uri = normalized_base(base_uri)
      unless @configured
        hook_reset if can_hook_reset? && !reset_registered?
        @configured = true
      end
      servers[base_uri].configure(&routes)
    end

    # Clear routes but don't stop servers. Meant to be called between tests.
    # Starting/stopping servers is relatively slow. They can be reused.
    def reset
      servers.values.each(&:clear_routes)
      @configured = false
    end

    # Stop all servers. This should only need to be called by tests that use
    # Kim directly (like kim_spec.rb).
    def teardown_cached_servers
      servers.values.each(&:teardown)
      servers.clear
      @configured = false
    end

    private

    def servers
      @servers ||= Hash.new{|hash, key| hash[key] = FakeServer.new(next_port)}
    end

    def next_port
      @last_port ||= 9000
      @last_port += 1
    end

    private

    def normalized_base(uri)
      HyperionUri.new(uri).base
    end

    # hook into the production code so we can redirect requests to the appropriate fake server
    def transform_uri(uri)
      server_uri = servers.keys.detect{|server_uri| normalized_base(server_uri) == uri.base}
      if server_uri
        new_uri = HyperionUri.new(uri)
        new_uri.base = "http://localhost:#{servers[server_uri].port}"
        logger.debug "Hyperion is redirecting #{uri}  ==>  #{new_uri}"
        new_uri
      else
        uri
      end
    end

  end
end
