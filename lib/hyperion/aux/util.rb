class Hyperion
  class Util
    def self.nil_if_error
      begin
        yield
      rescue StandardError
        return nil
      end
    end
  end
end
