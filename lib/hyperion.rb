require 'immutable_struct'
# Hyperion::Util.require_recursive '.' #TODO: extract the requiring into utils or someplace

require 'contracts'
require 'hyperion/contracts'
# include Contracts
# include Hyperion::Contracts

Dir.glob(File.join(File.dirname(__FILE__), 'hyperion/**/*.rb')).each{|path| require_relative(path)}
require 'typhoeus'
require 'oj'
require 'continuation'
require 'abstractivator/proc_ext'
require 'abstractivator/enumerable_ext'
require 'active_support/core_ext/object/blank'

class Hyperion
  include Headers
  include Formats
  include Logger

  # @param route [RestRoute]
  # @param body [String] the body to send with POST or PUT
  # @param additional_headers [Hash] headers to send in addition to the ones
  #   already determined by the route. Example: +{'User-Agent' => 'Mozilla/5.0'}+
  # @yield [result] yields the result if a block is provided
  # @yieldparam [HyperionResult]
  # @return [HyperionResult, Object] If a block is provided, returns the block's
  #   return value; otherwise, returns the result.
  def self.request(route, body=nil, additional_headers={}, &block)
    request_impl(route, body, additional_headers, &block)
  end

  # Contract RestRoute, Any, Hash, Proc => Or[HyperionResult, Object]
  def self.request_impl(route, body, additional_headers, &block)
    self.new(route).request(body, additional_headers, &block)
  end

  # @private
  def initialize(route)
    @route = route
  end

  # @private
  def request(body=nil, additional_headers={})
    all_headers = route_headers(route).merge(additional_headers)

    uri = transform_uri(route.uri).to_s
    log_request(route, uri)
    typho_result = Typho.request(uri,
                                 method: route.method,
                                 headers: all_headers,
                                 body: body && write(body, route.payload_descriptor))

    if block_given?
      callcc do |cont|
        yield make_result(typho_result, cont)
      end
    else
      make_result(typho_result)
    end
  end

  private

  def route
    @route
  end

  def transform_uri(uri)
    Hyperion.send(:transform_uri, uri)
  end

  # give Hyperion::Test a shot at changing the uri for stubbing purposes
  def self.transform_uri(uri)
    uri
  end

  def make_result(typho_result, continuation=nil)
    make = ->klass do
      # should this use the response 'Content-Type' instead of response_descriptor.format?
      read_body = ->{read(typho_result.body, route.response_descriptor)}
      status = HyperionResult::Status.method(:from_symbol)

      if typho_result.success?
        klass.new(route, status[:success], typho_result.code, read_body.call)

      elsif typho_result.timed_out?
        klass.new(route, status[:timed_out])

      elsif typho_result.code == 0
        klass.new(route, status[:no_response])

      elsif typho_result.code == 404
        klass.new(route, status[:bad_route], typho_result.code)

      elsif (400..499).include?(typho_result.code)
        hash_body = read_body.call
        err = ClientErrorResponse.from_attrs(hash_body) || hash_body
        klass.new(route, status[:client_error], typho_result.code, err)

      elsif (500..599).include?(typho_result.code)
        klass.new(route, status[:server_error], typho_result.code)

      else
        klass.new(route, status[:check_code], typho_result.code, read_body.call)

      end
    end

    if continuation
      result = make.call(PredicatingHyperionResult)
      result.instance_variable_set(:@continuation, continuation)
      result
    else
      make.call(HyperionResult)
    end
  end

  # @private
  class PredicatingHyperionResult < HyperionResult
    def when(condition, &action)
      pred = as_predicate(condition)
      if Util.nil_if_error{pred.call(self)}
        @continuation.call(action.call(self))
      end
      nil
    end

    private

    def as_predicate(condition)
      if Status.values.include?(condition)
        status_checker(condition)
      elsif condition.is_a?(Integer)
        code_checker(condition)
      elsif condition.is_a?(Range)
        range_checker(condition)
      elsif condition.respond_to?(:call)
        condition
      end
    end

    def status_checker(status)
      ->r{r.status == status}
    end

    def code_checker(code)
      ->r{r.code == code}
    end

    def range_checker(range)
      ->r{range.include?(r.code)}
    end
  end

end
