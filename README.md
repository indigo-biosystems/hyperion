# Hyperion

Hyperion is a Ruby REST client that follows certain conventions
layered on top of HTTP. The conventions implement best practices.
Hyperion provides an abstraction that makes it easy to follow these
conventions consistently across projects.

## Conventions

### Versioning

TBD

### Errors

## Using it

Hyperion revolves around the idea of a _route_, which is a combination of:

- HTTP method
- URI
- parameters that influence header generation and de/serialization
  - `ResponseDescriptor` (what kind of data do we want back)
    - influences the `Accept` header
  - `PayloadDescriptor` (what kind of data is being PUT or POSTed)
    - influences the `Content-Type` header

Hyperion automatically deserializes responses according to the
`ResponseDescriptor` and serializes the request payload according to
the `PayloadDescriptor`.

### Hyperion

Hyperion provides a basic interface for requesting routes.

```ruby
require 'hyperion'

route = RestRoute.new(:get, 'http://somesite.org/users/0', ResponseDescriptor.new('user', 1, :json))
result = Hyperion.request(route)
```

(Example of organizing routes, like AssaymaticRoutes)

You can pass `request` a block, in which case the return value of the
block becomes the return value of `request`.

```ruby
user = Hyperion.request(route) do |result|
  if result.status == HyperionResult::Status::SUCCESS
    User.new(result.body)
  end
end
```

Production quality error handling becomes hairy quickly, so hyperion
provides a mini DSL to make it easier. Conditions are tested in order.
When the first true condition is encountered, the associated block is
executed and becomes the return value of `request`.


```ruby
Hyperion.request(route) do |result|
  result.when(HyperionResult::Status::SUCCESS) { User.new(result.body) }
  result.when(400..499) { raise 'we screwed up' }
  result.when(500..599) { raise 'they screwed up' }
  result.when(evil) { exit(1) }
end

def evil
  proc do |result|
    result.body['things'].any?{|x| x['id'] == 666}
  end
end
```

A condition may be:

- a `HyperionResult::Status` enumeration member,
- an `ErrorInfo::Code` enumeration member,
- an HTTP code,
- a range of HTTP codes, or
- an arbitrary predicate.

To obviate copious structural tests in predicates, a predicate that
raises an exception is treated as a non-match. In the example above,
if the body didn't have a 'things' key, then the predicate would not
match, and hyperion would move on to the next predicate, if any.

Other examples:

```ruby
# POST
route = RestRoute.new(:post, 'http://somesite.org/users',
                      ResponseDescriptor.new('user', 1, :json),
                      PayloadDescriptor.new(:json))
result = Hyperion.request(route, body: {name: 'joe', email: 'joe@schmoe.com'})

# configure hyperion
Hyperion.configure do |config|
  config.vendor_string = 'indigobio-ascent'  # becomes part of the Accept header
end
```

### Superion

Superion layers more convenience onto Hyperion by helping dispatch the
response: rendering the response as an entity and dealing with errors.

```ruby
require 'superion'

class UserGateway
  include Superion

  def find(id)
    route = RestRoute.new(:get, "http://somesite.org/users/#{id}")
    user = request(route, render: as_user)
  end

  def as_user
    proc do |hash|
      User.new(hash)
    end
  end
end
```

On success, the 'render' proc has a chance to transform the body
(usually a Hash) into an internal representation (often an entity).

After rendering, a 'project' proc (the block) has a chance to project
the rendered entity; for example, by choosing a subdocument or field.

```ruby
def user_names
  route = RestRoute.new(:get, "http://somesite.org/users")
  user = request(route, render: as_users) { |users| users.map(&:name) }
end
```

Superion has three levels of dispatching:

- core,
- includer, and
- request.

_TBD: these terms could use improvement._

They are distinguished by their scope. The core handler is built into
superion. An includer handler affects all requests made by a
particular class. A request handler affects a particular request.

When superion receives a response, it passes the result through the
request, includer, and core handlers, in that order. The first handler
to match wins, and no further handlers are tried. If no handler
matches, then superion invokes the fallthrough handler.

The core handler handles the success case, and 400- and 500-level
errors. In the success case, the body is rendered and projected. In
the error cases, a `HyperionError` is raised. The message for 400s is
taken from the error response. The message for 500s contains the raw
string body. Specifically for 404, no body is available, so a special
error indicating an unimplemented route is raised in that case.

The includer handler is an optional method on the requesting class.

```ruby
class UserGateway
  include Superion

  def superion_handler(result)
    result.when(ErrorInfo::MISSING) { raise "The resource was not found: #{result.route}" }
    result.when(HyperionResult::Status::SERVER_ERROR) { ... }
  end
end
```

The request handler provides a convenient way to specify a handler as
a Hash for an individual `request` call. If a `superion_handler` looks
like:

```ruby
result.when(condition) { return_something }
```

then the equivalent request handler is

```ruby
{ condition => proc { return_something } }
```

Pass it as the `also_handle` option:

```ruby
  request(route, render: as_user, also_handle: { condition => proc { return_something } })
```

The fallthrough handler is an optional method in the requesting class.

```ruby
def superion_fallthrough(result)
  ...
end
```

If a result falls through and no `superion_fallthrough` method is
defined, an `HyperionError` is raised. 

### Testing

```ruby
require 'hyperion_test'

list_route = RestRoute.new(:get, "http://somesite.org/users")
find_route = RestRoute.new(:get, "http://somesite.org/users/123")

Hyperion.fake('http://somesite.org') do |svr|
  svr.allow(list_route) { [User.new('123'), User.new('123')].as_json }
  svr.allow(find_route) do |result|
    User.new(result.body['id']).as_json
  end
end
```

For simpler cases:

```ruby
list_route = RestRoute.new(:get, "http://somesite.org/users")
response = [User.new('123'), User.new('123')]
fake_route(list_route, response)
```

See the specs for details.
