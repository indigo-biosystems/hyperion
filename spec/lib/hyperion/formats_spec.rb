require 'spec_helper'

class Hyperion
  describe Formats do
    include Formats

    describe '#write' do
      it 'returns the input if the input is a string' do
        expect(write('hello', :json)).to eql 'hello'
      end
      it 'writes json' do
        expect(write({'a' => 1}, :json)).to be_json_eql '{"a":1}'
      end
      it 'allows protobuf format but just passes it through' do
        expect(write('x', :protobuf)).to eql 'x'
      end
    end

    describe '#read' do
      it 'returns nil if input is nil' do
        expect(read(nil, :json)).to be_nil
      end
      it 'read json' do
        expect(read('{"a":1}', :json)).to eql({'a' => 1})
      end
      it 'allows protobuf format but just passes it throughn' do
        expect(read('x', :protobuf)).to eql 'x'
      end
    end
  end
end
