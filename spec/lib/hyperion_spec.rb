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
          'From' => 'dev@indigobio.com',
          'Expect' => nil
      }

      expect(Hyperion::Typho).to receive(:request).
                                     with(uri, {method: method, headers: expected_headers, body: 'Ventura'}).
                                     and_return(make_typho_response(200, write({'foo' => 'bar'}, :json)))

      result = Hyperion.request(route, body, additional_headers)
      expect(result).to be_a HyperionResult
      expect(result.status).to eql HyperionStatus::SUCCESS
      expect(result.code).to eql 200
      expect(result.body).to eql({'foo' => 'bar'})
      expect(result.route).to eql route
    end

    context 'serialization' do
      let!(:method){:post}
      let!(:uri){'http://somesite.org:5000/path/to/resource'}
      let!(:rd){ResponseDescriptor.new('data_type', 1, :json)}
      let!(:pd){PayloadDescriptor.new(:json)}
      let!(:route){RestRoute.new(method, uri, rd, pd)}
      let!(:expected_headers){{
          'Accept' => "application/vnd.indigobio-ascent.#{rd.type}-v#{rd.version}+#{rd.format}",
          'Content-Type' => 'application/json',
          'Expect' => nil
      }}
      it 'deserializes the response' do
        allow(Hyperion::Typho).to receive(:request).and_return(make_typho_response(200, '{"a":"b"}'))
        result = Hyperion.request(route)
        expect(result.body).to eql({'a' => 'b'})
      end
      it 'serializes the payload' do
        expect(Hyperion::Typho).to receive(:request).
                                       with(uri, {method: method, headers: expected_headers, body: '{"c":"d"}'}).
                                       and_return(make_typho_response(200, write({}, :json)))
        Hyperion.request(route, {'c' => 'd'})
      end
      it 'deserializes 400-level errors to ClientErrorResponse' do
        client_error = ClientErrorResponse.new('oops', [], ClientErrorCode::MISSING)
        allow(Hyperion::Typho).to receive(:request).
                                      with(uri, {method: method, headers: expected_headers, body: '{"c":"d"}'}).
                                      and_return(make_typho_response(400, write(client_error.as_json, :json)))
        result = Hyperion.request(route, {'c' => 'd'})
        expect(result.body).to be_a ClientErrorResponse
        expect(result.body.message).to eql 'oops'
        expect(result.body.code).to eql ClientErrorCode::MISSING
      end
    end

    context 'when a block is provided' do
      let!(:route){RestRoute.new(:get, 'http://yum.com', ResponseDescriptor.new('x', 1, :json))}
      it 'calls the block with the result' do
        stub_typho_response(200)
        yielded = nil
        Hyperion.request(route) do |r|
          yielded = r
        end
        expect(yielded).to be_a HyperionResult
      end
      it 'returns the return value of the block' do
        stub_typho_response(200)
        request_and_expect(123) do |_r|
          123
        end
      end
      context 'when switching on result properties' do
        it 'returns the value of the matched block' do
          stub_typho_response(200)
          request_and_expect(456) do |r|
            r.when(200) { 456 }
            123
          end
        end
        it 'returns the value of the request block if nothing matched' do
          stub_typho_response(999)
          request_and_expect(123) do |r|
            r.when(200) { 456 }
            123
          end
          request_and_expect(nil) do |r|
            r.when(200) { 456 }
          end
        end
        it 'matches return codes' do
          stub_typho_response(200)
          request_and_expect(true) do |r|
            r.when(200) { true }
          end
        end
        it 'matches return code ranges' do
          stub_typho_response(404)
          request_and_expect(true) do |r|
            r.when(400..499) { true }
          end
        end
        it 'matches result states' do
          stub_typho_response(999, true)
          request_and_expect(true) do |r|
            r.when(HyperionStatus::TIMED_OUT) { true }
          end
        end
        it 'matches client error codes' do
          response = ClientErrorResponse.new('oops', [ClientErrorDetail.new(ClientErrorCode::MISSING, 'thing')])
          stub_typho_response(400, false, response)
          request_and_expect(true) do |r|
            r.when(ClientErrorCode::MISSING) { true }
          end
        end
        it 'matches arbitrary predicates' do
          stub_typho_response(999)
          request_and_expect(true) do |r|
            r.when(->r{r.code == 999 && r.status == HyperionStatus::CHECK_CODE}) { true }
          end
        end
        it 'the predicate can be arity 0' do
          stub_typho_response(999)
          request_and_expect(123) do |r|
            r.when(->{true}) { 123 }
          end
        end
        it 'when a predicate raises an error, it is caught and the predicate does not match' do
          stub_typho_response(400)
          request_and_expect(true) do |r|
            r.when(->r{raise 'oops'}) { false }
            r.when(400) { true }
          end
        end
        it 'when the action raises an error, it is not caught' do
          stub_typho_response(400)
          expect do
            request_and_expect(true) do |r|
              r.when(400) { raise 'oops' }
            end
          end.to raise_error 'oops'
        end
        it 'stops after the first match' do
          stub_typho_response(404)
          request_and_expect('got 404') do |r|
            r.when(HyperionStatus::TIMED_OUT) { 'timed out' }
            r.when(300) { 'got 400-level' }
            r.when(404) { 'got 404' }
            r.when(400..499) { 'got 400-level' }
          end
        end
      end

      def request_and_expect(return_value, &block)
        expect(Hyperion.request(route, &block)).to eql return_value
      end
    end

    def stub_typho_response(code, timed_out=false, response={})
      allow(Hyperion::Typho).to receive(:request).and_return(make_typho_response(code, write(response, :json), timed_out))
    end

    def make_typho_response(code, body, timed_out=false)
      r = double
      allow(r).to receive(:success?) { 200 <= code && code < 300 }
      allow(r).to receive(:code) { code }
      allow(r).to receive(:body) { body }
      allow(r).to receive(:timed_out?) { timed_out }
      r
    end

  end
end
