class Hyperion
  class FakeServer
    Rule = ImmutableStruct.new(:method, :path, :headers, :handler, :rest_route)
    class Rule
      alias_method :verb, :method
    end
    Request = ImmutableStruct.new(:body)
  end
end
