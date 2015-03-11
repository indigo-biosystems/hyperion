require 'rspec'
require 'hyperion'

describe HyperionResult do
  describe '#to_s' do
    let!(:route) { RestRoute.new(:get, 'http://somesite.org/foo/bar') }

    def make_result(status, code=400)
      HyperionResult.new(route, status, code)
    end

    it 'pretty prints the result' do
      msg = "Success: #{route.to_s}"
      expect(make_result(HyperionResult::Status::SUCCESS).to_s).to eql msg

      msg = "Timed out: #{route.to_s}"
      expect(make_result(HyperionResult::Status::TIMED_OUT).to_s).to eql msg

      msg = "No response: #{route.to_s}"
      expect(make_result(HyperionResult::Status::NO_RESPONSE).to_s).to eql msg

      msg = "Bad route (404): #{route.to_s}"
      expect(make_result(HyperionResult::Status::BAD_ROUTE, 404).to_s).to eql msg

      msg = "Client error: #{route.to_s}"
      expect(make_result(HyperionResult::Status::CLIENT_ERROR, 400).to_s).to eql msg

      msg = "Server error: #{route.to_s}"
      expect(make_result(HyperionResult::Status::SERVER_ERROR, 500).to_s).to eql msg

      msg = "HTTP 432: #{route.to_s}"
      expect(make_result(HyperionResult::Status::CHECK_CODE, 432).to_s).to eql msg
    end
  end
end

describe ResponseDescriptor do
  include Hyperion::Headers

  describe '#to_s' do
    it 'returns the short mimetype' do
      rd = ResponseDescriptor.new('ttt', 999, :json)
      expect(rd.to_s).to eql short_mimetype(rd)
    end
  end

end
