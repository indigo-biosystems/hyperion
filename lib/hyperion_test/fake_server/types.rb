class Hyperion
  class FakeServer
    Rule = ImmutableStruct.new(:method, :path, :headers, :handler, :rest_route)
    Request = ImmutableStruct.new(:body)
  end
end
