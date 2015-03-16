require 'immutable_struct'
require 'mimic'
require 'hyperion/headers'
require 'hyperion/formats'
require 'uri'
require 'hyperion_test/fake_server'

class Hyperion
  class << self
    # maintains a collection of fake servers, one for each base_uri.
    # manages rspec integration for automatic teardown after each test.

    include Formats
    include Headers
    include TestFrameworkHooks
    include Logger

    def fake(base_uri, &routes)
      base_uri = normalized_base(base_uri)
      if !@running
        hook_teardown if can_hook_teardown? && !teardown_registered?
        @running = true
      end
      servers[base_uri].configure(&routes)
    end

    def teardown
      servers.values.each(&:teardown)
      servers.clear
      @running = false
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

