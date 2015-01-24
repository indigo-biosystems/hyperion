require 'immutable_struct'
require 'mimic'
require 'hyperion/headers'
require 'hyperion/formats'
require 'uri'
require 'hyperion-test/fake_server'

class Hyperion
  class << self
    include Formats
    include Headers
    include TestFrameworkHooks

    def fake(base_uri, &routes)
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
      server_uri = servers.keys.detect{|server_uri| base_matches?(URI(server_uri), uri)}
      if server_uri
        new_uri = change_base(URI(uri), URI("http://localhost:#{servers[server_uri].port}"))
        puts "Hyperion redirected #{uri}  ==>  #{new_uri}"
        new_uri
      else
        uri
      end
    end

    def base_matches?(a, b)
      a.scheme == b.scheme && a.host == b.host && a.port == b.port
    end

    def change_base(target_uri, source_uri)
      uri = target_uri.dup
      uri.scheme = source_uri.scheme
      uri.host = source_uri.host
      uri.port = source_uri.port
      uri
    end
  end
end
