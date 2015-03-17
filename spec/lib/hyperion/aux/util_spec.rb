require 'rspec'
require 'hyperion/aux/util'

class Hyperion
  describe Util do

    describe '::nil_if_error' do
      it 'catches StandardErrors in the block' do
        expect(Util.nil_if_error { raise 'oops' }).to be_nil
      end
      it 'does not catch Exceptions in the block' do
        expect{Util.nil_if_error { raise Exception }}.to raise_error Exception
      end
    end

    describe '::guard' do
      it 'raises a BugException if the value is invalid' do
        expect{Util.guard_param(7, 'a string', String)}.to report 'You passed me 7, which is not a string'
        expect{Util.guard_param('foo', 'any old number', Numeric)}.to report 'You passed me "foo", which is not any old number'
        expect{Util.guard_param(:zero, 'callable') { |x| x.respond_to?(:call) }}.to report 'You passed me :zero, which is not callable'
      end

      def report(msg)
        raise_error BugError, msg
      end
    end

  end
end
