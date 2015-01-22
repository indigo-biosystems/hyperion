require 'immutable_struct'
require 'mimic'
require 'hyperion/headers'
require 'hyperion/formats'

class Hyperion
  class << self
    include Formats
    include Headers

    # TODO: when doing remappings, print to stdout the remapping so users can be aware
    # TODO: (e.g., "Mapping 'hello.com' to 'localhost:12345'")
    def fake(base_uri_with_port)
      if can_hook_teardown? && !teardown_registered?
        rspec_hooks.register(:prepend, :after, :each, &(Hyperion.method(:teardown).to_proc))
      end
      original_uri, @fake_port = split_uri(base_uri_with_port)
      base_uri_mapping[original_uri] = 'http://localhost'
      setup = Setup.new
      yield setup
      run_fake_server(setup)
    end

    def teardown(*args)
      base_uri_mapping.clear
      routes.clear
      rules.clear
      @mimic_running = false
      Mimic.cleanup!
    end

    private

    def teardown_registered?
      rspec_hooks[:after][:example].to_a.any? do |hook|
        hook.block.source_location == Hyperion.method(:teardown).to_proc.source_location
      end
    end

    def can_hook_teardown?
      RSpec.current_example
    end

    def rspec_hooks
      RSpec.current_example.example_group.hooks
    end

    def run_fake_server(setup)
      routes.concat(setup.rules.map { |r| [r.method, r.path] }.uniq)
      rules.concat(setup.rules)
      this = self
      Mimic.cleanup! if @mimic_running
      Mimic.mimic(port: @fake_port) do
        this.send(:routes).each do |(method, path)|
          send(method, path) do
            path_matched = this.send(:rules).select { |r| r.method == method && r.path == path }
            matched = path_matched.detect { |r|
              this.send(:sinatrize_headers, r.headers).subhash?(request.env)
            }
            matched.handler.call(this.send(:make_req_obj, request.body.read, request.env['CONTENT_TYPE']))
          end
        end
      end
      @mimic_running = true
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

    def remapped_base_uri(base_uri)
      base_uri_mapping.fetch(base_uri) { |x| x }
    end

    def base_uri_mapping
      @base_uri_mapping ||= {}
    end

    def routes
      @routes ||= []
    end

    def rules
      @rules ||= []
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

      # allow(route)
      # allow(method, path, headers={})
      def allow(*args, &handler)
        if args.size == 1 && args.first.is_a?(RestRoute)
          route = args.first
          rules << Rule.new(route.method, route.uri.path, default_headers(route.response_params), handler)
        else
          method, path, headers = args
          headers ||= {}
          rules << Rule.new(method, path, headers, handler)
        end
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
