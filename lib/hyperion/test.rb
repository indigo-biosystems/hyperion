require 'immutable_struct'
require 'mimic'
require 'hyperion/headers'
require 'hyperion/formats'

class Hyperion
  class << self
    include Formats
    include Headers

    def fake(base_uri_with_port)
      setup = Setup.new
      yield setup
      run_fake_server(setup)
    end

    def run_fake_server(setup)
      routes = setup.rules.map{|r| [r.method, r.path]}.uniq
      Mimic.mimic do
        routes.each do |(method, path)|
          send(method, path) do
            matched = rules.
                select{|r| r.method == method && r.path == path}.
                detect{|r| is_subhash(self.headers, headers)}
            matched.handler.call(make_req_obj(request.body.read, headers['Content-Type']))
          end
        end
      end
    end

    private

    def make_req_obj(raw_body, content_type)
      Request.new(read(raw_body, format_for(content_type)))
    end

    def is_subhash(hash, subhash)
      subhash.each_pair.all{|k, v| hash[k] == v}
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

  def uri_base

  end

end