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
  end
end
