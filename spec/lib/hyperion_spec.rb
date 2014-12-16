require 'rspec'
require 'hyperion'
require 'stringio'

describe Hyperion do

  describe '#get' do
    it 'performs a GET using Typhoeus' do
      uri = 'http://example.com:12345/hi/there'
      expected_opts = {
          method: :get,
          headers: {
              'Accept' => 'application/vnd.indigobio-ascent.ttt-v999+json'
          },
          body: nil
      }
      expect(Hyperion::Typho).to receive(:request).with(uri, expected_opts) { mock_json_response(200, {'a' => 1}) }
      result = Hyperion.new(uri, Hyperion::ResponseParams.new('ttt', 999, :json)).get
      expect(result.status).to eql Hyperion::Result::Status::SUCCESS
      expect(result.code).to eql 200
      expect(result.body).to eql({'a' => 1})
    end
  end

  describe '#post' do
    it 'performs a POST using Typhoeus' do
      uri = 'http://example.com:12345/hi/there'
      expected_opts = {
          method: :post,
          headers: {
              'Accept' => 'application/vnd.indigobio-ascent.ttt-v999+json',
              'Content-Type' => 'application/json'
          },
          body: '{"info":888}'
      }
      expect(Hyperion::Typho).to receive(:request).with(uri, expected_opts) { mock_json_response(200, {'a' => 1}) }
      result = Hyperion.new(uri, Hyperion::ResponseParams.new('ttt', 999, :json)).post(Oj.dump({'info' => 888}), :json)
      expect(result.status).to eql Hyperion::Result::Status::SUCCESS
      expect(result.code).to eql 200
      expect(result.body).to eql({'a' => 1})
    end
  end

  describe '::request' do
    it 'delegates to #request' do
      method = :xyz
      path, uri, response_params = 3.times.map{double}
      route = RestRoute.new(method, path, uri, response_params)
      hyp = double
      arg1, arg2 = double, double
      expect(Hyperion).to receive(:new).with(uri, response_params).and_return(hyp)
      expect(hyp).to receive(method).with(arg1, arg2)

      Hyperion.request(route, arg1, arg2)
    end
  end

  def mock_json_response(code, hash)
    r = double
    allow(r).to receive(:success?) { 200 <= code && code < 300 }
    allow(r).to receive(:code) { code }
    allow(r).to receive(:body) { Oj.dump(hash) }
    r
  end
end
