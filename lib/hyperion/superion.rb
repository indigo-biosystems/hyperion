require 'hyperion'

module Superion

  # @param [RestRoute] route The route to request
  # @option opts [Object] :body The payload to POST/PUT. Usually a Hash or Array.
  # @option opts [Hash<predicate, transformer>] :also_handle Additional handlers to
  #   use besides the default handlers. A predicate is an integer HTTP code, an
  #   integer Range of HTTP codes, a HyperionResult::Status enumeration value,
  #   or a predicate proc. A transformer is a procedure which accepts a
  #   HyperionResult and returns the final value to return from `request`
  # @option opts [Proc] :render A transformer, usually a proc returned by
  #   `as` or `as_many`. Only called on HTTP 200.
  # @yield [rendered] Yields to allow an additional transformation.
  #   Only called on HTTP 200.
  def request(route, opts={}, &project)
    guard_param(route, RestRoute, 'a RestRoute')
    guard_param(opts, Hash, 'an options hash')

    body = opts[:body]
    additional_handler_hash = opts[:also_handle] || {}
    render = opts[:render] || Proc.identity
    project = project || Proc.identity

    Hyperion.request(route, body) do |result|
      all_handlers = [hash_handler(additional_handler_hash),
                      handler_from_including_class,
                      built_in_handler(project, render)]

      all_handlers.each { |handlers| handlers.call(result) }
      fallthrough(result)
    end
  end

  # PW: deprecate
  def missing
    proc do |result|
      result.body.errors.detect(:code, ErrorInfo::Code::MISSING)
    end
  end

  private

  def guard_param(value, expected_type, what)
    value.is_a?(expected_type) or fail "You passed me #{value.inspect}, which is not #{what}"
  end

  def hash_handler(hash)
    proc do |result|
      hash.each_pair do |condition, consequent|
        result.when(condition) { Proc.loose_call(consequent, [result]) }
      end
    end
  end

  def handler_from_including_class
    respond_to?(:superion_handler, true) ? method(:superion_handler).loosen_args : proc{}
  end

  def built_in_handler(project, render)
    proc do |result|
      result.when(HyperionResult::Status::SUCCESS, &Proc.pipe(:body, render, project))
      result.when(HyperionResult::Status::BAD_ROUTE, &method(:on_bad_route))
      result.when(HyperionResult::Status::CLIENT_ERROR, &method(:on_client_error))
      result.when(HyperionResult::Status::SERVER_ERROR, &method(:on_server_error))
    end
  end

  def on_bad_route(response)
    body = ClientErrorResponse.new("Got HTTP 404 for #{response.route}. Is the route implemented?")
    report_client_error(response.route, body)
  end

  def on_client_error(response)
    report_client_error(response.route, response.body)
  end

  def report_client_error(route, body)
    generic_msg = "The request failed: #{route}"

    if body.is_a?(ClientErrorResponse)
      hyperion_raise body.message
    elsif body.nil?
      hyperion_raise generic_msg
    else
      hyperion_raise "#{generic_msg}: #{body}"
    end
  end

  def on_server_error(response)
    hyperion_raise "#{response.route}\n#{response.body}"
  end

  def fallthrough(result)
    if respond_to?(:superion_fallthrough, true)
      Proc.loose_call(method(:superion_fallthrough), [result])
    else
      hyperion_raise 'Superion error: the response did not match any conditions ' +
                         'and no superion_fallthrough method is defined: ' + result.to_s
    end
  end
end
