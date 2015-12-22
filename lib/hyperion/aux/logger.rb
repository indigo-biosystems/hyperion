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

    def log_result(result)
      logger.error(dump_json(result.as_json)) if should_log_result?(result)
    end

    def log_stub(rule)
      mr = rule.mimic_route
      logger.debug "Stubbed #{mr.method.to_s.upcase} #{mr.path}"
      log_headers(rule.headers, logger)
    end

    private

    def log_headers(headers, logger)
      h = headers.delete_if { |_k, v| v.nil? }
      logger.info(dump_json(h))
    end

    def should_log_result?(result)
      result.body && result.status != HyperionStatus::SUCCESS
    end

    def dump_json(obj)
      Oj.dump(obj)
    rescue
      obj.inspect
    end
  end
end
