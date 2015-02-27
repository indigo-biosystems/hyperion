class Hyperion
  module Logger
    class << self
      attr_accessor :level
    end

    def logger
      rails_logger_available? ? Rails.logger : default_logger
    end

    def log_request(route, uri, headers)
      logger.debug "Requesting #{route.method.to_s.upcase} #{uri}"
      log_headers(headers)
    end

    def log_stub(rule)
      mr = rule.mimic_route
      logger.debug "Stubbed #{mr.method.to_s.upcase} #{mr.path}"
      log_headers(rule.headers)
    end

    private

    def rails_logger_available?
      Kernel.const_defined?(:Rails) && !Rails.logger.nil?
    end

    def default_logger
      logger = ::Logger.new($stdout)
      logger.level = Hyperion::Logger.level || ::Logger::DEBUG
      logger
    end

    def log_headers(headers)
      headers.each_pair { |k, v| logger.debug "    #{k}: #{v}" }
      logger.debug '' if headers.any?
    end
  end
end
