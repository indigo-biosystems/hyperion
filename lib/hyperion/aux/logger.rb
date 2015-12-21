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
      logger.error(pretty_log(result.body)) if should_log_result?(result)
    end

    def log_stub(rule)
      mr = rule.mimic_route
      logger.debug "Stubbed #{mr.method.to_s.upcase} #{mr.path}"
      log_headers(rule.headers, logger)
    end

    private

    def log_headers(headers, logger)
      h = headers.delete_if { |_k, v| v.nil? }
      logger.info(pretty_log(h))
    end

    def should_log_result?(result)
      result.body && result.status != HyperionStatus::SUCCESS
    end

    def pretty_log(obj)
      if obj.is_a? ClientErrorResponse
        pretty_log(obj.as_json)
      elsif obj.is_a? Hash
        obj.map { |k, v| "#{k}=#{pretty_log(v)}" }.join(', ')
      elsif obj.is_a? Array
        obj.map { |x| pretty_log(x) }
      else
        obj.inspect
      end
    end
  end
end
