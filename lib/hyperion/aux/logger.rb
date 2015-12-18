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

    def log_error_response(response_body)
      logger.error(log_message(response_body))
    end

    def log_stub(rule)
      mr = rule.mimic_route
      logger.debug "Stubbed #{mr.method.to_s.upcase} #{mr.path}"
      log_headers(rule.headers, logger)
    end

    private

    def log_headers(headers, logger)
      h = headers.keep_if { |k| k != 'Expect' }
      logger.info(log_message(h))
    end

    def log_message(obj)
      if obj.is_a?(Hash)
        obj.map { |k, v| "#{k}=#{v.inspect}" }.join(', ')
      else
        obj.to_s
      end
    end
  end
end
