class Hyperion
  module Logger
    class << self
      attr_accessor :level
    end

    def logger
      rails_logger_available? ? Rails.logger : default_logger
    end

    def with_request_logging(route, uri, headers)
      log_request_start(route, uri, headers)
      start = Time.now
      begin
        yield
      ensure
        stop = Time.now
        log_request_end(((stop - start) * 1000).round)
      end
    end

    def log_stub(rule)
      mr = rule.mimic_route
      logger.debug "Stubbed #{mr.method.to_s.upcase} #{rule.rest_route ? rule.rest_route.uri : mr.path}"
      log_headers(rule.headers)
    end

    private

    def log_request_start(route, uri, headers)
      logger.debug "Requesting #{route.method.to_s.upcase} #{uri}"
      log_headers(headers)
    end

    def log_request_end(ms)
      logger.debug "Completed in #{ms}ms"
      logger.debug ''
    end

    def rails_logger_available?
      Kernel.const_defined?(:Rails) && !Rails.logger.nil?
    end

    def default_logger
      logger = ::Logger.new($stdout)
      logger.level = Hyperion::Logger.level || ::Logger::DEBUG
      logger
    end

    def log_headers(headers)
      headers.each_pair { |k, v| logger.debug "    #{k}: #{v}" unless k == 'Expect' }
    end
  end
end
