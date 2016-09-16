require 'rack'
require 'securerandom'
require 'thread'
require 'ostruct'
require 'active_support/core_ext/string/inflections'
require 'hyperion_test/kim/matcher'

class Hyperion
  class Kim
    # A dumb fake web server.
    # This is minimal object wrapper around Rack/WEBrick. WEBrick was chosen
    # because it comes with ruby and we're not doing rocket science here.
    # Kim runs Rack/WEBrick in a separate thread and keeps an array of
    # handlers. A handler is simply a predicate on a request object
    # and a function to handle the request should the predicate return truthy.
    # When rack notifies us of a request, we dispatch it to the first handler
    # with a truthy predicate.
    #
    # Again, what we're trying to do is very simple. Most of the existing complexity
    # is due to
    # - thread synchronization
    # - unmangling WEBrick's header renaming
    # - loosening the requirements on what a handler function must return
    #
    # To support path parameters (e.g., /people/:name), a predicate may return
    # a Request object as a truthy value, augmented with additional params.
    # When the predicate returns a Request, the augmented request object is
    # passed to the handler function in place of the original request.

    Handler = Struct.new(:pred, :func)
    Request = Struct.new(:verb,     # 'GET' | 'POST' | ...
                         :path,     # String
                         :params,   # OpenStruct
                         :headers,  # Hash[String => String]
                         :body)     # String
    class Request
      alias_method :method, :verb
      def merge(other)
        merge_params(other.params)
      end
      def merge_params(other_params)
        params = OpenStruct.new(self.params.to_h.merge(other_params.to_h))
        Request.new(verb, path, params, headers, body)
      end
    end

    def initialize(port:)
      @port = port
      @handlers = []
      @lock = Mutex.new # controls access to this instance of Kim (via public methods and callbacks)
    end

    def self.webrick_mutex
      @webrick_mutex ||= Mutex.new # controls access to the Rack::Handler::WEBrick singleton
    end

    def start
      # Notes on synchronization:
      #
      # The only way to start a handler is with static method ::run
      # which touches singleton instance variables. webrick_mutex
      # ensures only one thread is in the singleton at a time.
      #
      # A threadsafe queue is used to notify the calling thread
      # that the server thread has started. The caller needs to
      # wait so it can obtain the webrick instance.

      @lock.synchronize do
        raise 'Cannot restart' if @stopped
        Kim.webrick_mutex.synchronize do
          q = Queue.new
          @thread = Thread.start do
            begin
              opts = {Port: @port, Logger: ::Logger.new('/dev/null'), AccessLog: []} # hide output
              Rack::Handler::WEBrick.run(method(:handle_request), opts) do |webrick|
                q.push(webrick)
              end
            ensure
              $stderr.puts "Hyperion fake server on port #{@port} exited unexpectedly!" unless @stopped
            end
          end
          @webrick = q.pop
        end
      end
    end

    def stop
      @lock.synchronize do
        return if @stopped
        @stopped = true
        @webrick.shutdown
        @thread.join
        @webrick = nil
        @thread = nil
      end
    end

    # Add a handler. Returns a proc that removes the handler.
    def add_handler(matcher_or_pred, &handler_proc)
      @lock.synchronize do
        handler = Handler.new(Matcher.wrap(matcher_or_pred), handler_proc)
        @handlers.unshift(handler)
        remover = proc { @lock.synchronize { @handlers.delete(handler) } }
        remover
      end
    end

    def clear_handlers
      @lock.synchronize do
        @handlers = []
      end
    end

    private
    def handle_request(env)
      @lock.synchronize do
        req = request_for(env)
        x = handle(req)
        x = massage_response(x)
        x = validate_response(x)
        x
      end
    end

    def request_for(env)
      verb = env['REQUEST_METHOD']
      path = env['PATH_INFO']
      params = OpenStruct.new(read_query_params(env['QUERY_STRING']))
      headers = read_headers(env)
      body = env['rack.input'].gets
      Request.new(verb, path, params, headers, body)
    end

    def read_query_params(query_string)
      query_string
        .split('&')
        .map { |kv| kv.split('=') }
        .to_h
    end

    def read_headers(env)
      # similar to https://github.com/ruby/ruby/blob/32674b167bddc0d737c38f84722986b0f228b44b/lib/webrick/cgi.rb#L217-L226
      env.each_pair
        .select { |k, _| mangled_header?(k) }
        .map { |k, v| [unmangle_header_key(k), v] }
        .to_h
    end

    def mangled_header?(h)
      h.start_with?('HTTP_') || %w(CONTENT_TYPE CONTENT_LENGTH).include?(h)
    end

    def unmangle_header_key(k)
      k.gsub(/^HTTP_/, '')
        .split('_')
        .map(&:titlecase)
        .join('-')
    end

    def handle(req)
      pred_value, func = @handlers.lazy
        .map { |h| [h.pred.call(req), h.func] }
        .select { |(pv, _)| pv }
        .first || [nil, no_route_matched_func]
      func.call(pred_value.is_a?(Request) ? pred_value : req)
    end

    def massage_response(r)
      if triplet?(r)
        r[0] = r[0].to_s   # code
        r[1] = r[1] || {}  # headers
        r[2] = *r[2]       # body/bodies (coerce to array)
        r[2].map!(&:to_s)
        r
      elsif r.is_a?(String)
        ['200', {}, [r]]
      else
        r
      end
    end

    def validate_response(r)
      triplet?(r) or return server_error("Invalid response, not a size-3 array: #{r.inspect}.")
      http_code?(r[0]) or return server_error("Invalid response, invalid http code: #{r[0].inspect}")
      headers?(r[1]) or return server_error("Invalid response, invalid header hash: #{r[1].inspect}")
      bodies?(r[2]) or return server_error("Invalid response, invalid bodies array: #{r[2].inspect}")
      r
    end

    def no_route_matched_func
      proc do
        ['404', error_headers, ['Request matched no routes.']]
      end
    end

    def triplet?(x)
      x.is_a?(Array) && x.size == 3
    end

    def http_code?(x)
      return false unless x.respond_to?(:to_i)
      v = x.to_i
      100 <= v && v < 600
    end

    def headers?(x)
      # TODO: check for valid keys and values
      x.is_a?(Hash)
    end

    def bodies?(x)
      x.is_a?(Array) && x.all? { |v| v.is_a?(String) }
    end

    def server_error(msg)
      ['500', error_headers, [msg]]
    end

    def error_headers
      {'Content-Type' => 'text/plain'}
    end
  end
end
