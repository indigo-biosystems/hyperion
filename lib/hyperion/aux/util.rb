require 'hyperion/aux/bug_error'

class Hyperion
  class Util
    def self.nil_if_error
      begin
        yield
      rescue StandardError
        return nil
      end
    end

    def self.guard_param(value, what, expected_type=nil, &pred)
      pred ||= proc { |x| x.is_a?(expected_type) }
      pred.call(value) or fail BugError, "You passed me #{value.inspect}, which is not #{what}"
    end

    # reimplement callcc because ruby has deprecated it
    def self.callcc()
      in_scope = true
      cont = proc do |retval|
        unless in_scope
          raise "Cannot invoke this continuation. Control has left this continuation's scope."
        end
        raise CallCcError.new(retval)
      end
      yield(cont)
    rescue CallCcError => e
      e.retval
    ensure
      in_scope = false
    end

    class CallCcError < RuntimeError
      attr_accessor :retval
      def initialize(retval)
        @retval = retval
      end
    end
  end
end
