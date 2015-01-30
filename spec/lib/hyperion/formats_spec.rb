require 'spec_helper'

class Hyperion
  describe Formats do
    include Formats

    describe '#write' do
      it 'returns the input if the input is a string or nil' do
        expect(write('hello', :json)).to eql 'hello'
        expect(write(nil, :json)).to be_nil
      end
      it 'returns the input if format is nil' do
        expect(write('hello', nil)).to eql 'hello'
      end
      it 'accepts format as a symbol' do
        expect(write({'a' => 1}, :json)).to eql '{"a":1}'
      end
      it 'accepts format as a descriptor' do
        descriptor = double(format: :json)
        expect(write({'a' => 1}, descriptor)).to eql '{"a":1}'
      end

      context 'formats' do
        it 'writes json' do
          expect(write({'a' => 1}, :json)).to be_json_eql '{"a":1}'
        end
        it 'allows protobuf format but just passes it through' do
          expect(write('x', :protobuf)).to eql 'x'
        end
      end
    end

    describe '#read' do
      it 'returns nil if input is nil' do
        expect(read(nil, :json)).to be_nil
      end
      it 'returns the input if format is nil' do
        expect(read('abc', nil)).to eql 'abc'
      end
      it 'accepts format as a symbol' do
        expect(read('{"a":1}', :json)).to eql({'a' => 1})
      end
      it 'accepts format as a descriptor' do
        descriptor = double(format: :json)
        expect(read('{"a":1}', descriptor)).to eql({'a' => 1})
      end

      context 'formats' do
        it 'read json' do
          expect(read('{"a":1}', :json)).to eql({'a' => 1})
        end
        it 'allows protobuf format but just passes it through' do
          expect(read('x', :protobuf)).to eql 'x'
        end
      end
    end
  end
end
