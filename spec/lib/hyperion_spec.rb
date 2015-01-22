require 'rspec'
require 'hyperion'
require 'stringio'

describe Hyperion do
  describe '::request' do
    include Hyperion::Formats

    it 'delegates to Typhoeus' do
      method = :post
      uri = 'http://somesite.org:5000/path/to/resource'
      rd = ResponseDescriptor.new('data_type', 1, :json)
      pd = PayloadDescriptor.new(:protobuf)
      route = RestRoute.new(method, uri, rd, pd)
      body = 'Ventura'
      additional_headers = {'From' => 'dev@indigobio.com'}

      expected_headers = {
          'Accept' => "application/vnd.indigobio-ascent.#{rd.type}-v#{rd.version}+#{rd.format}",
          'Content-Type' => 'application/x-protobuf',
          'From' => 'dev@indigobio.com'
      }

      expect(Hyperion::Typho).to receive(:request).
                                     with(uri, {method: method, headers: expected_headers, body: 'Ventura'}).
                                     and_return(mock_json_response(200, write({'foo' => 'bar'}, :json)))

      result = Hyperion.request(route, body, additional_headers)
      expect(result).to be_a HyperionResult
      expect(result.status).to eql HyperionResult::Status::SUCCESS
      expect(result.code).to eql 200
      expect(result.body).to eql({'foo' => 'bar'})
    end

    def mock_json_response(code, body)
      r = double
      allow(r).to receive(:success?) { 200 <= code && code < 300 }
      allow(r).to receive(:code) { code }
      allow(r).to receive(:body) { body }
      r
    end

  end
end
