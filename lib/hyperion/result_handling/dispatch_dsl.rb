require 'hyperion/aux/util'
require 'hyperion/types/hyperion_result'

class Hyperion
  # This is a DSL of sorts that gives the `request` block a nice way
  # to dispatch the result based on status, HTTP code, etc.
  module DispatchDsl
    def when(condition, &action)
      pred = as_predicate(condition)
      is_match = Util.nil_if_error { Proc.loose_call(pred, [self]) }
      if is_match
        return_value = action.call(self)
        @escape.call(return_value)
      else
        nil
      end
    end

    def __set_escape_continuation__(k)
      @escape = k
    end

    private

    def as_predicate(condition)
      if HyperionResult::Status.values.include?(condition)
        status_checker(condition)
      elsif condition.is_a?(Integer)
        code_checker(condition)
      elsif condition.is_a?(Range)
        range_checker(condition)
      elsif condition.respond_to?(:call)
        condition
      end
    end

    def status_checker(status)
      proc { |r| r.status == status }
    end

    def code_checker(code)
      proc { |r| r.code == code }
    end

    def range_checker(range)
      proc { |r| range.include?(r.code) }
    end
  end
end
