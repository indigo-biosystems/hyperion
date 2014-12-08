require 'rspec'
require 'hyperion'
require 'stringio'

describe Hyperion do

  describe '#get' do
    it 'performs a GET using Typhoeus' do
      uri = double
      expected_opts = {
          method: :get,
          headers: {
            'Accept' => 'application/vnd.indigobio-ascent.ttt-v999+json'
          },
          body: nil
      }
      expect(Hyperion::Typho).to receive(:request).with(uri, expected_opts) { mock_json_response(200, {'a' => 1}) }
      result = Hyperion.get(uri, Hyperion::ResponseParams.new('ttt', 999, 'json'))
      expect(result.status).to eql Hyperion::Result::Status::SUCCESS
      expect(result.code).to eql 200
      expect(result.body).to eql({'a' => 1})
    end
  end

  describe '#post' do
    it 'performs a POST using Typhoeus' do
      uri = double
      expected_opts = {
          method: :post,
          headers: {
              'Accept' => 'application/vnd.indigobio-ascent.ttt-v999+json',
              'Content-Type' => 'application/json'
          },
          body: '{"info":888}'
      }
      expect(Hyperion::Typho).to receive(:request).with(uri, expected_opts) { mock_json_response(200, {'a' => 1}) }
      result = Hyperion.post(uri, Hyperion::ResponseParams.new('ttt', 999, 'json'), Oj.dump({'info' => 888}), 'json')
      expect(result.status).to eql Hyperion::Result::Status::SUCCESS
      expect(result.code).to eql 200
      expect(result.body).to eql({'a' => 1})
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
