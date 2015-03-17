require 'hyperion/formats'
require 'hyperion/result_handling/dispatching_hyperion_result'
require 'hyperion/types/hyperion_result'
require 'hyperion/types/client_error_response'

class Hyperion
  # Produces a hyperion result object from a typhoeus result object
  class ResultMaker
    include Hyperion::Formats

    def self.make(route, typho_result, continuation=nil)
      self.new(route).make(typho_result, continuation)
    end

    def initialize(route)
      @route = route
    end

    def make(typho_result, continuation=nil)
      if continuation
        result = make_from_typho(typho_result, DispatchingHyperionResult)
        result.__set_escape_continuation__(continuation)
        result
      else
        make_from_typho(typho_result, HyperionResult)
      end
    end

    private

    attr_reader :route

    def make_from_typho(typho_result, result_class)
      # TODO: should this use the response's 'Content-Type' instead of response_descriptor.format?
      read_body = proc { read(typho_result.body, route.response_descriptor) }
      code = typho_result.code

      if typho_result.success?
        result_class.new(route, HyperionStatus::SUCCESS, code, read_body.call)

      elsif typho_result.timed_out?
        result_class.new(route, HyperionStatus::TIMED_OUT)

      elsif code == 0
        result_class.new(route, HyperionStatus::NO_RESPONSE)

      elsif code == 404
        result_class.new(route, HyperionStatus::BAD_ROUTE, code)

      elsif (400..499).include?(code)
        hash_body = read(typho_result.body, :json)
        err = ClientErrorResponse.from_attrs(hash_body) || hash_body
        result_class.new(route, HyperionStatus::CLIENT_ERROR, code, err)

      elsif (500..599).include?(code)
        result_class.new(route, HyperionStatus::SERVER_ERROR, code, read_body.call)

      else
        result_class.new(route, HyperionStatus::CHECK_CODE, code, read_body.call)
      end
    end

  end
end
