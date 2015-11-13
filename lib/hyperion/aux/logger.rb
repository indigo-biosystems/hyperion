require 'logatron/logatron'

class Hyperion
  module Logger

    def logger
      Logatron
    end

    def with_request_logging(route, uri, headers)
      Logatron.log(msg: "Hyperion #{route.method.to_s.upcase} #{uri}") do |logger|
        log_headers(headers, logger)
        yield
      end
    end

    def log_stub(rule)
      mr = rule.mimic_route
      logger.debug "Stubbed #{mr.method.to_s.upcase} #{mr.path}"
      log_headers(rule.headers, logger)
    end

    private

    def log_headers(headers, logger)
      headers.each_pair { |k, v| logger.info "    #{k}: #{v}" unless k == 'Expect' }
    end
  end
end
