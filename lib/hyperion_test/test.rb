require 'immutable_struct'
require 'mimic'
require 'hyperion/headers'
require 'hyperion/formats'
require 'uri'
require 'hyperion_test/fake_server'

class Hyperion
  class << self
    include Formats
    include Headers
    include TestFrameworkHooks
    include Logger

    # Contract Or[String, URI] => Any
    def fake(base_uri, &routes)
      base_uri = HyperionUri.new(base_uri).base # normalize it
      if !@running
        hook_teardown if can_hook_teardown? && !teardown_registered?
        @running = true
      end
      servers[base_uri].configure(&routes)
    end

    def teardown
      servers.values.each{|s| s.teardown}
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

    # redirect normal Hyperion requests to the appropriate fake server
    def transform_uri(uri)
      server_uri = servers.keys.detect{|server_uri| HyperionUri.new(server_uri).base == uri.base}
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

