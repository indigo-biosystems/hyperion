require 'hyperion_test'

# a simple wrapper around Hyperion::fake for the typical
# use case of one faked route.
def fake_route(route, return_value=nil, &block)
  if return_value && block
    fail 'cannot provide both a return_value and block'
  end
  block = block || proc{return_value}
  Hyperion.fake(route.uri.base) do |svr|
    svr.allow(route, &block)
  end
end
