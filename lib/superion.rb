require 'hyperion'

# A hyperion interface that abstracts common usage patterns.
#
# On success, a 'render' proc has a chance to transform the body
# (usually a Hash) into an internal representation (often an entity).
# After rendering, a 'project' proc has a chance to project the entity;
# for example, by choosing a subdocument or field.
#
# There are three layers of error handling: core, includer, and request.
#
# The core handler handles the success case and 400-level errors. When
# the response is 400-level, the core handler reads the body as a
# ClientErrorResponse object. Specifically for 404, the body is not
# available, so a special error indicating an unimplemented route is
# raised in that case.
#
# The includer handler is a 'superion_handler' method implemented by
# the including class/module. This method has the same contract as
# the block passed to Hyperion::request. See the hyperion specs for
# and example.
#
# The request handler provides a convenient way to specify a handler
# as a Hash for an individual `request` call. If a `superion_handler`
# looks like:
#   request.when(condition) { return_something }
#
# then the request handler looks like
#
#   { condition => proc { return_something } }
#
# First the request handler runs, then the includer handler, then the
# core handler. Thus, specific handlers override generic ones.
# Finally, if no handlers matched, the includer's 'superion_fallthrough'
# method is called.
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

  def missing
    # TODO: will be cleaner when hyperion puts the parsed error on HyperionResult
    proc do |result|
      result.body.is_a?(Hash) && result.body['errors'] && result.body['errors'].any? && result.body.errors.first['code'] == 'missing'
    end
  end

  private

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
      result.when(HyperionResult::Status::SUCCESS, &Proc.compose(project, render, :body.to_proc))
      result.when(404, &method(:on_404))
      result.when(400..499, &method(:on_400))
    end
  end

  def on_404(response)
    # TODO: use Hyperion::Error instead
    body = { 'message' => "Got HTTP 404 for #{response.route}. Is the route implemented?" }
    report_400(response.route, body)
  end

  def on_400(response)
    report_400(response.route, response.body)
  end

  def report_400(route, body)
    generic_msg = "The request failed: #{route}"
    raise generic_msg unless body
    specific_msg = body.is_a?(Hash) ? body['message'] : nil
    raise "#{generic_msg}: #{body}" unless specific_msg
    raise specific_msg
  end

  def fallthrough(result)
    Proc.loose_call(method(:superion_fallthrough), [result]) if respond_to?(:superion_fallthrough, true)
  end
end
