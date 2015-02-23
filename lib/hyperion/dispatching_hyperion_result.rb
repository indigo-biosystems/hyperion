require 'hyperion/types/hyperion_result'

class Hyperion
  class DispatchingHyperionResult < HyperionResult
    def when(condition, &action)
      pred = as_predicate(condition)
      if Util.nil_if_error{pred.call(self)}
        @continuation.call(action.call(self))
      end
      nil
    end

    private

    def as_predicate(condition)
      if Status.values.include?(condition)
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
      ->r{r.status == status}
    end

    def code_checker(code)
      ->r{r.code == code}
    end

    def range_checker(range)
      ->r{range.include?(r.code)}
    end
  end
end
