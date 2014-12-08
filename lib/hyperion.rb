require_relative './hyperion/util.rb'
require 'immutable_struct'
Hyperion::Util.require_recursive '.'

require 'typhoeus'
require 'oj'

class Hyperion
  include Headers

  ResponseParams = ImmutableStruct.new(:type, :version, :format)

  def self.get(uri, response_params)
    self.new(uri, response_params).get
  end

  def self.post(uri, response_params, body, body_format)
    self.new(uri, response_params).post(body, body_format)
  end

  def initialize(uri, response_params)
    @uri = uri
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
    all_headers = default_headers(@response_params.type, @response_params.version, @response_params.format).merge(headers)
    response = Typho.request(@uri, method: method, headers: all_headers, body: body)
    make_result(response)
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
