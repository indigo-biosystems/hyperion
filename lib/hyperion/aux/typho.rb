require 'hyperion/aux/lazy'
require 'hyperion/types/hyperion_error'
require 'hyperion/aux/logger'

class Hyperion
  # all Typhoeus interation goes through this module
  # for maintenance and mocking purposes
  class Typho
    class << self
      include Hyperion::Logger

      def request(uri, options={}, &continue)
        request_internal(Typhoeus::Request.new(uri, options), continue || Proc.identity)
      end

      def multi
        hydra = Typhoeus::Hydra.new
        hydras.push(hydra)
        yield
        requests = hydra.queued_requests.dup
        hydra.run
      ensure
        hydras.pop
        log_request_end(format_requests(requests))
      end

      private

      def hydras
        @hydras ||= []
      end

      def request_internal(typho_request, continue)
        if hydras.any?
          hydras.last.queue(typho_request)
          lazy do
            typho_request.response or raise HyperionError, 'The "multi" block must return accessing results'
            continue.call(typho_request.response)
          end
        else
          response = typho_request.run
          log_request_end(format_requests([typho_request]))
          continue.call(response)
        end
      end

      def format_requests(requests)
        requests.map{|r| "#{r.options[:method].to_s.upcase} #{r.base_url}"}
      end
    end
  end
end
