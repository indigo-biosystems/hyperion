require 'hyperion/aux/util'
require 'hyperion/types/hyperion_result'
require 'hyperion/types/error_info'

class Hyperion
  # This is a DSL of sorts that gives the `request` block a nice way
  # to dispatch the result based on status, HTTP code, etc.
  module DispatchDsl

    def __set_escape_continuation__(k)
      @escape = k
    end

    def when(condition, &action)
      pred = as_predicate(condition)
      is_match = Util.nil_if_error { Proc.loose_call(pred, [self]) }
      if is_match
        return_value = action.call(self)
        @escape.call(return_value)  # non-local exit
      else
        nil
      end
    end

    private

    def as_predicate(condition)
      if condition.enum_type == HyperionResult::Status
        status_checker(condition)

      elsif condition.enum_type == ErrorInfo::Code
        client_error_code_checker(condition)

      elsif condition.is_a?(Integer)
        http_code_checker(condition)

      elsif condition.is_a?(Range)
        range_checker(condition)

      elsif condition.callable?
        condition

      else
        fail "Not a valid condition: #{condition.inspect}"
      end
    end

    def status_checker(status)
      proc { |r| r.status == status }
    end

    def client_error_code_checker(code)
      proc do |r|
        r.status == HyperionResult::Status::CLIENT_ERROR &&
            r.body.errors.detect(:code, code)
      end
    end

    def http_code_checker(code)
      proc { |r| r.code == code }
    end

    def range_checker(range)
      proc { |r| range.include?(r.code) }
    end
  end
end
