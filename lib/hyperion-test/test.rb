require 'immutable_struct'
require 'mimic'
require 'hyperion/headers'
require 'hyperion/formats'

class Hyperion
  class << self
    include Formats
    include Headers

    def fake(base_uri_with_port)
      unless @registered_hook
        RSpec.current_example.example_group.hooks.register(:prepend, :after, :each) do
          Hyperion.teardown
        end
        @registered_hook = true
      end
      original_uri, @fake_port = split_uri(base_uri_with_port)
      base_uri_mapping[original_uri] = 'http://localhost'
      setup = Setup.new
      yield setup
      run_fake_server(setup)
    end

    def run_fake_server(setup)
      routes = setup.rules.map { |r| [r.method, r.path] }.uniq
      this = self
      Mimic.mimic(port: @fake_port) do
        routes.each do |(method, path)|
          send(method, path) do
            path_matched = setup.rules.select { |r| r.method == method && r.path == path }
            matched = path_matched.detect { |r|
              this.send(:sinatrize_headers, r.headers).subhash?(request.env)
            }
            matched.handler.call(this.send(:make_req_obj, request.body.read, request.env['CONTENT_TYPE']))
          end
        end
      end
    end

    def teardown
      base_uri_mapping.clear
      Mimic.cleanup!
    end

    private

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

    def remapped_base_uri(base_uri)
      base_uri_mapping.fetch(base_uri) { |x| x }
    end

    def base_uri_mapping
      @base_uri_mapping ||= {}
    end

    def make_req_obj(raw_body, content_type)
      body = raw_body.empty? ? '' : read(raw_body, format_for(content_type))
      Request.new(body)
    end

    def is_subhash(hash, subhash)
      subhash.each_pair.all? { |k, v| hash[k] == v }
    end

    class Setup
      def rules
        @rules ||= []
      end

      def allow(method, path, headers={}, &handler)
        rules << Rule.new(method, path, headers, handler)
      end
    end

    Rule = ImmutableStruct.new(:method, :path, :headers, :handler)

    Request = ImmutableStruct.new(:body)
  end
  private

  def uri_base
    self.class.send(:remapped_base_uri, @uri_base)
  end
end

class Hash
  def subhash?(hash)
    each_pair.all? { |k, v| hash[k] == v }
  end
end
