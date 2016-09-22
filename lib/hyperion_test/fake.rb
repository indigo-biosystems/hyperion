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
      servers.values.each { |s| server_pool.check_in(s) }
      servers.clear
      @configured = false
    end

    # Stop all servers. This should only need to be called by tests that use
    # Kim directly (like kim_spec.rb).
    def teardown_cached_servers
      reset
      server_pool.clear
    end

    private

    def servers
      @servers ||= Hash.new { |hash, key| hash[key] = server_pool.check_out }
    end

    def server_pool
      @server_pool ||= ServerPool.new
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
