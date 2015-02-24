require 'hyperion/formats'

class Hyperion
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
        result = make_from_typho(DispatchingHyperionResult, typho_result)
        result.instance_variable_set(:@continuation, continuation)
        result
      else
        make_from_typho(HyperionResult, typho_result)
      end
    end

    def make_from_typho(klass, typho_result)
      # should this use the response 'Content-Type' instead of response_descriptor.format?
      read_body = ->{read(typho_result.body, route.response_descriptor)}
      status = HyperionResult::Status
      code = typho_result.code

      if typho_result.success?
        klass.new(route, status::SUCCESS, code, read_body.call)

      elsif typho_result.timed_out?
        klass.new(route, status::TIMED_OUT)

      elsif code == 0
        klass.new(route, status::NO_RESPONSE)

      elsif code == 404
        klass.new(route, status::BAD_ROUTE, code)

      elsif (400..499).include?(code)
        hash_body = read(typho_result.body, :json)
        err = ClientErrorResponse.from_attrs(hash_body) || hash_body
        klass.new(route, status::CLIENT_ERROR, code, err)

      elsif (500..599).include?(code)
        klass.new(route, status::SERVER_ERROR, code)

      else
        klass.new(route, status::CHECK_CODE, code, read_body.call)

      end
    end

    private
    attr_reader :route

  end
end
