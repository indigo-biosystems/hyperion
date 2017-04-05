require 'hyperion_test'

# A simple wrapper around Hyperion::fake for the typical
# use case of one faked route. The return value can either be specified
# as an argument or as a function of the request (using the block).
#
# @param [RestRoute] route The route to handle
# @param [Hash, String, rack_response] return_value The data to return in response to a request
# @yield [Hyperion::FakeServer::Request] Yields a request object containing the deserialized request body
# @yieldreturn [Hash, String, rack_response] The data to return in response to a request
#
# The structure of a rack response is specified at http://rack.github.io
# Hyperion loosens these requirements a little. For instance, the headers
# hash may be nil, and the body does not need to be wrapped in an array.
# See kim_spec.rb for details. The massaging is done in FakeServer#massage_response.
def fake_route(route, return_value=nil, &block)
  if return_value && block
    fail 'cannot provide both a return_value and block'
  end
  block = block || proc{return_value}
  Hyperion.fake(route.uri.base) do |svr|
    svr.allow(route, &block)
  end
end
