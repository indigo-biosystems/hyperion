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
    # handlers pairs. A handler is simply a predicate on a request object
    # and a function to handle the request should the predicate return truthy.
    # When rack notifies us of a request, we dispatch it to the first handler
    # with a truthy predicate.
    #
    # Again, what we're trying to do is very simple. Most of the complexity is due to
    # - thread synchronization
    # - unmangling WEBrick's header renaming
    # - loosening the requirements on what a handler function must return

    Handler = Struct.new(:pred, :func)
    Request = Struct.new(:verb, :path, :params, :headers, :body)
    class Request
      alias_method :method, :verb
    end

    def initialize(port:)
      @port = port
      @handlers = []
      @lock = Mutex.new # controls access to this instance of Kim (via public methods and callbacks)
    end

    def self.webrick_mutex
      @webrick_mutex ||= Mutex.new # controls access to Rack::Handler::WEBrick singleton
    end

    def start
      # Notes on synchronization:
      #
      # The only way to start a handler is with static method ::run
      # which touches singleton instance variables. webrick_mutex
      # ensures only one thread is in the singleton at a time.
      #
      # A queue is used to notify the calling thread that
      # the server thread has started. The caller needs to wait
      # so it can obtain the webrick instance.

      @lock.synchronize do
        raise 'Cannot restart' if @stopped
        self.class.webrick_mutex.synchronize do
          q = Queue.new
          @thread = Thread.start do
            opts = {Port: @port, Logger: ::Logger.new('/dev/null'), AccessLog: []} # hide output
            Rack::Handler::WEBrick.run(method(:handle_request), opts) do |webrick|
              q.push(webrick)
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

    def add_handler(matcher_or_pred, &handler_proc)
      @lock.synchronize do
        handler = Handler.new(Matcher.wrap(matcher_or_pred), handler_proc)
        @handlers.unshift(handler)
        # @handlers << handler
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
        req = request_from_env(env)
        handler = find_handler(req)
        if handler
          x = handler.func.call(req)
          x = massage_response(x)
          x = validate_response(x)
          x
        else
          no_route_matched_response
        end
      end
    end

    def request_from_env(env)
      verb = env['REQUEST_METHOD']
      path = env['PATH_INFO']
      params = OpenStruct.new(read_query_params(env['QUERY_STRING']))
      headers = read_headers(env)
      body = env['rack.input'].gets
      Request.new(verb, path, params, headers, body)
    end

    def read_query_params(query_string)
      query_string.split('&')
        .map { |kv| kv.split('=') }
        .to_h
    end

    def read_headers(env)
      # along the same lines as https://github.com/ruby/ruby/blob/32674b167bddc0d737c38f84722986b0f228b44b/lib/webrick/cgi.rb#L217-L226
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

    def find_handler(req)
      @handlers.detect { |h| h.pred.call(req) }
    end

    def massage_response(r)
      if triplet?(r)
        r[0] = r[0].to_s
        r[1] = r[1] || {}
        r[2] = !r[2].is_a?(Array) ? [r[2]] : r[2]
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

    def no_route_matched_response
      ['404', error_headers, ['Request matched no routes.']]
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