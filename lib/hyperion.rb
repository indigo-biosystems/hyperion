require 'immutable_struct'
# Hyperion::Util.require_recursive '.' #TODO: extract the requiring into utils or someplace
Dir.glob(File.join(File.dirname(__FILE__), '*.rb')).each{|path| require_relative(path)}
Dir.glob(File.join(File.dirname(__FILE__), 'hyperion/**/*.rb')).each{|path| require_relative(path)}
require 'typhoeus'
require 'oj'

class Hyperion
  include Headers
  include Formats

  # @param route [RestRoute]
  # @param body [String] the body to send with POST or PUT
  # @param additional_headers [Hash] headers to send in addition to the ones
  #   already determined by the route. Example: +{'User-Agent' => 'Mozilla/5.0'}+
  def self.request(route, body=nil, additional_headers={})
    self.new(route).request(body, additional_headers)
  end

  # @private
  def initialize(route)
    @route = route
  end

  # @private
  def request(body=nil, additional_headers={})
    all_headers = route_headers(route).merge(additional_headers)
    response = Typho.request(transform_uri(route.uri).to_s, method: route.method, headers: all_headers, body: body)
    make_result(response)
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

  def make_result(t)
    if t.success?
      HyperionResult.new(HyperionResult::Status::SUCCESS, t.code, read(t.body, :json))
    elsif t.timed_out?
      HyperionResult.new(HyperionResult::Status::TIMED_OUT)
    elsif t.code == 0
      HyperionResult.new(HyperionResult::Status::NO_RESPONSE)
    else
      HyperionResult.new(HyperionResult::Status::CHECK_CODE, t.code, read(t.body, :json))
    end
  end

end
