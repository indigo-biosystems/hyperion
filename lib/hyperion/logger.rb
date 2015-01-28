class Hyperion
  module Logger
    include Hyperion::Headers

    def logger
      @logger ||= ::Logger.new(STDOUT)
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
