class Hyperion
  # all Typhoeus interation goes through this module
  # for maintenance and mocking purposes
  class Typho
    def self.request(uri, options={})
      Typhoeus::Request.new(uri, options).run
    end
  end
end
