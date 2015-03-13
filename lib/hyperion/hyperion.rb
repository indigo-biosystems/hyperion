require 'hyperion/headers'
require 'hyperion/formats'
require 'hyperion/aux/logger'
require 'hyperion/aux/typho'
require 'hyperion/result_handling/result_maker'

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
    self.new(route).request(body, additional_headers, &block)
  end

  # @private
  def initialize(route)
    @route = route
  end

  # @private
  def request(body=nil, additional_headers={}, &block)
    uri = transform_uri(route.uri).to_s
    with_request_logging(route, uri, route_headers(route)) do
      typho_result = Typho.request(uri,
                                   method: route.method,
                                   headers: build_headers(additional_headers),
                                   body: write(body, route.payload_descriptor))
      hyperion_result_for(typho_result, block)
    end
  end

  private

  attr_reader :route

  def build_headers(additional_headers)
    route_headers(route).merge(additional_headers)
  end

  def hyperion_result_for(typho_result, block)
    result_maker = ResultMaker.new(route)
    if block
      # callcc allows control to "jump" back here when the first predicate matches
      callcc do |cont|
        block.call(result_maker.make(typho_result, cont))
      end
    else
      result_maker.make(typho_result)
    end
  end

  def transform_uri(uri)
    Hyperion.send(:transform_uri, uri)
  end

  # give Hyperion::Test a shot at changing the uri for stubbing purposes
  def self.transform_uri(uri)
    uri
  end
end
