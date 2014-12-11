class Hyperion
  # all Typhoeus interation goes through this module for mocking purposes
  class Typho
    def self.request(base_url, options = {})
      Typhoeus::Request.new(base_url, options).run
    end
  end
end
