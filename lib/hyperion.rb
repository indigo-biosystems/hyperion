require_relative './hyperion/util'
require 'immutable_struct'
# Hyperion::Util.require_recursive '.' #TODO: extract the requiring into utils or someplace
require_relative './response_params'
Dir.glob(File.join(File.dirname(__FILE__), "hyperion/**/*.rb")).each{|path| require_relative(path)}
require 'typhoeus'
require 'oj'

class Hyperion
  include Headers

  # TODO: possibly provide an "overload" that takes a base_uri and path separately
  def self.get(uri, response_params)
    self.new(uri, response_params).get
  end

  def self.post(uri, response_params, body, body_format)
    self.new(uri, response_params).post(body, body_format)
  end

  def initialize(uri, response_params)
    @uri_base, @port, @path = split_uri(uri)
    @response_params = response_params
  end

  def get
    request(:get)
  end

  def post(body, body_format)
    request(:post, post_headers(body_format), body)
  end

  private

  def request(method, headers={}, body=nil)
    all_headers = default_headers(@response_params).merge(headers)
    response = Typho.request(full_uri, method: method, headers: all_headers, body: body)
    make_result(response)
  end

  def full_uri
    File.join("#{uri_base}:#{@port}", @path)
  end

  # let Hyperion::Test pass us a fake one
  def uri_base
    @uri_base
  end

  def split_uri(uri)
    self.class.split_uri(uri)
  end

  def self.split_uri(uri)
    m = uri.match(%r{(?<uri_base>(?<proto>https?)://[^:/]+)(?::(?<port>\d+))?(?<path>/.*)?})
    [m[:uri_base], m[:port] || default_port(m[:proto]), m[:path] || '/']
  end

  def self.default_port(proto)
    case proto
      when 'http'; 80
      when 'https'; 443
      else; "Unexpected proto: #{proto}"
    end
  end

  # give Hyperion::Test a shot at changing the uri for stubbing purposes
  def transform_uri(uri)
    uri
  end

  def make_result(t)
    if t.success?
      Result.new(Result::Status::SUCCESS, t.code, Oj.load(t.body))
    elsif t.timed_out?
      Result.new(Result::Status::TIMED_OUT)
    elsif t.code == 0
      Result.new(Result::Status::NO_RESPONSE)
    else
      Result.new(Result::Status::CHECK_CODE, t.code, Oj.load(t.body))
    end
  end

end
