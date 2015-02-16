require 'rspec'
require 'hyperion'

describe HyperionResult do
  describe '#to_s' do
    let!(:route) { RestRoute.new(:get, 'http://somesite.org/foo/bar') }
    def make_result(status)
      HyperionResult.new(route, status, 432)
    end
    it 'pretty prints the result' do
      msg = "Success: #{route.to_s}"
      expect(make_result(HyperionResult::Status::SUCCESS).to_s).to eql msg

      msg = "Timed out: #{route.to_s}"
      expect(make_result(HyperionResult::Status::TIMED_OUT).to_s).to eql msg

      msg = "No response: #{route.to_s}"
      expect(make_result(HyperionResult::Status::NO_RESPONSE).to_s).to eql msg

      msg = "HTTP 432: #{route.to_s}"
      expect(make_result(HyperionResult::Status::CHECK_CODE).to_s).to eql msg
    end
  end
end
