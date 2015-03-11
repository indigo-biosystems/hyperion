require 'rspec'
require 'hyperion'

describe HyperionResult do
  describe '#to_s' do
    let!(:route) { RestRoute.new(:get, 'http://site.com/things') }
    it 'returns something reasonable' do
      verify_to_s(HyperionResult::Status::TIMED_OUT, nil, "Timed out: #{route.to_s}")
      verify_to_s(HyperionResult::Status::CLIENT_ERROR, 400, "Client error: #{route.to_s}")
      verify_to_s(HyperionResult::Status::CHECK_CODE, 321, "HTTP 321: #{route.to_s}")
    end

    def verify_to_s(status, code, expected)
      expect(HyperionResult.new(route, status, code).to_s).to eql expected
    end
  end
end
