class Hyperion
  class FakeServer
    MimicRoute = ImmutableStruct.new(:method, :path)
    Rule = ImmutableStruct.new(:mimic_route, :headers, :handler, :rest_route)
    Request = ImmutableStruct.new(:body)
  end
end
