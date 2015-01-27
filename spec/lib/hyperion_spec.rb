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
                                     and_return(make_typho_response(200, write({'foo' => 'bar'}, :json)))

      result = Hyperion.request(route, body, additional_headers)
      expect(result).to be_a HyperionResult
      expect(result.status).to eql HyperionResult::Status::SUCCESS
      expect(result.code).to eql 200
      expect(result.body).to eql({'foo' => 'bar'})
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
        request_and_expect(123) do |r|
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
        it 'matches result states' do
          stub_typho_response(999, true)
          request_and_expect(true) do |r|
            r.when(HyperionResult::Status::TIMED_OUT) { true }
          end
        end
        it 'matches arbitrary predicates' do
          stub_typho_response(999)
          request_and_expect(true) do |r|
            r.when(->r{r.code == 999 && r.status == HyperionResult::Status::CHECK_CODE}) { true }
          end
        end
      end

      def request_and_expect(return_value, &block)
        expect(Hyperion.request(route, &block)).to eql return_value
      end
    end

    def stub_typho_response(code, timed_out=false)
      allow(Hyperion::Typho).to receive(:request).and_return(make_typho_response(code, write({}, :json), timed_out))
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
