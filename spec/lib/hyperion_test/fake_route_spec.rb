require 'rspec'
require 'hyperion/requestor'
require 'hyperion_test'

describe 'fake_route' do
  include Hyperion::Requestor

  context 'for multipart form data as a part of the body' do
    let(:uri) { File.join('http://test.com', 'convert') }
    let(:response_descriptor) { ResponseDescriptor.new('converted_sample', 1, :json) }
    let(:route) { RestRoute.new(:post, uri, response_descriptor) }
    let(:response) { {'x' => 1} }

    it 'it fakes the given response' do
      fake_route(route, JSON.dump(response))
      expect(make_request(route)).to eql response
    end

    def make_request(route)
      body = Multipart.new(file: File.open(File.expand_path('spec/fixtures/test'), 'r'))
      request(route, body: body)
    end
  end
end