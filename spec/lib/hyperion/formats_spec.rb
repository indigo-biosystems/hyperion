require 'spec_helper'
require 'time'
require 'hyperion'

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
        context 'when writing json' do
          it 'writes hashes with string keys' do
            expect(write({'a' => 1}, :json)).to be_json_eql '{"a":1}'
          end
          it 'writes hashes with symbol keys' do
            expect(write({a: 1}, :json)).to be_json_eql '{"a":1}'
          end
          context 'when writing times' do
            let!(:time) { Time.parse('2015-02-13 08:40:20.321 +1200').localtime('+12:00') }
            it 'writes Time objects in UTC ISO 8601 format using the timezone that was passed in with milliseconds precision' do
              expect(write({'a' => time}, :json)).to be_json_eql '{"a":"' + time.localtime('+12:00').iso8601(3) + '"}'
            end
            it 'preserves default behavior for non-hyperion code' do
              expect(Oj.dump({'a' => time})).to start_with '{"a":{"^t":' # be non-specific, since this changes based on something outside the control of bundler
            end
          end
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
      it 'returns the input if the input is not parseable' do
        expect(read('abc', :json)).to eql 'abc'
      end
      context 'when reading json' do
        it 'accepts format as a symbol' do
          expect(read('{"a":1}', :json)).to eql({'a' => 1})
        end
        it 'reads times as strings' do
          # sadly, Oj does not appear to support reading real Time objects, even when using
          # its own representation ({"^t":1423834820.321})
          expect(read('{"a":"2015-02-13T13:40:20.321Z"}', :json)['a']).to eql '2015-02-13T13:40:20.321Z'
        end
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
