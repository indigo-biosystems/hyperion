class Hyperion
  module Logger
    include Hyperion::Headers

    def logger
      Hyperion::Logger.logger
    end

    # static so config-like files like spec_helper.rb can set the log level globally
    def self.logger
      Kernel.const_defined?(:Rails) ? Rails.logger : default_logger
    end

    def self.default_logger
      @default_logger ||= ::Logger.new($stdout)
    end

    def log_request(route, uri)
      logger.debug "Requesting #{route.method.to_s.upcase} #{uri}"
      log_headers(route_headers(route))
    end

    def log_stub(rule)
      mr = rule.mimic_route
      logger.debug "Stubbed #{mr.method.to_s.upcase} #{mr.path}"
      log_headers(rule.headers)
    end

    private

    def log_headers(headers)
      headers.each_pair { |k, v| logger.debug "    #{k}: #{v}" }
      logger.debug '' if headers.any?
    end
  end
end
