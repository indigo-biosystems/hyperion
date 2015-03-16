require 'hyperion'
require 'hyperion/headers'

class Hyperion
  describe Headers do
    include Headers

    before :each do
      Hyperion.configure do |config|
        config.vendor_string = 'schmindigo-descent'
      end
    end

    let!(:uri){'http://somesite.org'}

    describe '#route_headers' do
      it 'creates an accept header for the response descriptor' do
        headers = route_headers(RestRoute.new(:get, uri, ResponseDescriptor.new('ttt', 999, :json)))
        expect(headers['Accept']).to eql 'application/vnd.schmindigo-descent.ttt-v999+json'
      end
      it 'creates a content-type header for the payload descriptor' do
        headers = route_headers(RestRoute.new(:get, uri, ResponseDescriptor.new('ttt', 999, :json), PayloadDescriptor.new(:json)))
        expect(headers['Content-Type']).to eql 'application/json'
      end
    end

    describe '#content_type_for' do
      it 'accepts format as a symbol' do
        expect(content_type_for(:json)).to eql 'application/json'
      end
      it 'accepts format as a descriptor' do
        descriptor = double(format: :json)
        expect(content_type_for(descriptor)).to eql 'application/json'
      end
      it 'returns the content type for the given format' do
        expect(content_type_for(:json)).to eql 'application/json'
        expect(content_type_for(:protobuf)).to eql 'application/x-protobuf'
      end
      it 'returns application/octet-stream if the format is unknown' do
        expect(content_type_for(:aaa)).to eql 'application/octet-stream'
      end
    end

    describe '#format_for' do
      it 'returns the format for the given content type' do
        expect(format_for('application/json')).to eql :json
        expect(format_for('application/x-protobuf')).to eql :protobuf
      end
      it 'raises an error if the content type is unknown' do
        expect{format_for('aaa/bbb')}.to raise_error
      end
    end

    describe '#short_mimetype' do
      it 'returns the short mime type' do
        expect(short_mimetype(ResponseDescriptor.new('ttt', 999, :json))).to eql 'ttt-v999+json'
      end
    end

  end
end
