# DEPRECATED: this code	has moved into ascent-web

# ~~Hyperion~~
[![Build Status](https://travis-ci.org/indigo-biosystems/hyperion.svg)](https://travis-ci.org/indigo-biosystems/hyperion) 

Hyperion is a Ruby REST client that follows certain conventions
layered on top of HTTP. The conventions implement best practices
surrounding versioning, error reporting, and crafting an API for
consumption by third parties. Hyperion provides abstractions that
make it easy to follow these conventions consistently across
projects.

This document describes the conventions, then demonstrates how to
use the API, and finally shows how to test your client-side code.

## Conventions

The conventions are modeled after [GitHub's Developer API](https://developer.github.com/v3/).

### Versioning

According to best practices, hyperion uses both _resource_ versioning and
_message_ versioning.

#### Message versioning

A client sends a _request_ to the server, and the server returns a
_response_. The request and response each have a message type with a
well specified structure. When placing the request, the client
specifies the type of messages it expects back. For PUT, POST, and
PATCH requests, the client also specifies the message type of the
payload it is sending with the request.

A client might send a request with the header:

`Accept: application/vnd.indigobio-ascent.user-v1+json`

which indicates that the server must return an "ascent.user" message, version
1, formatted as JSON. If the server does not support this, it must
return a 400-level error (discussed below).

A client POSTing a new user also includes the header:

`Content-Type: application/json`

indicating that it is sending JSON. The server takes the Accept header
message type to be the type of the request payload.
<!--- ^ seems fishy -->

The message version is incremented when the message structure changes.

_Note: Message types are currently established via documentation. In
the future, it would be desirable for them to be declared precisely in
a [protobuf](https://github.com/google/protobuf)-like form, which would
allow for generated documentation, simpler serialization code,
automatic validation, and enhanced logging and diagnostics._

#### Resource versioning

Less frequently, the semantics of a given resource change. There are
several ways a server can route a particular resource version,
including:

- `/v2/` - incorporating the version in the URI
- `?v=2` - accepting the version as a query parameter
- `v2.archiver.indigobio.com` - incorporating the version in the hostname
- creating a differently named resource altogether

Hyperion does not expressly support any of these conventions, although
it may in the future.


### Client Errors

The server always returns 400-level errors as exactly 400; no
distinction is made in the HTTP response code. Instead, the server
returns a well-defined "client error response" structure that contains

- a human-oriented error message, and
- a machine-oriented list of "error detail" structures.

The _message_ describes the problem. The _error details_ provide
enough information to begin resolving the problem.

An error detail consists of:

- code (not to be confused with the HTTP status code, _e.g._, 200)
- reason
- resource
- field
- value

The _code_ is an enumeration value (_e.g._, "missing", "invalid",
"unsupported") which describes the type of problem with the request.
<!--- ^ consider renaming "code" to "problem" -->

The _reason_ explains why the problem occurred.

The problem is associated with a particular _resource_, and perhaps
more specifically with a particular _field_ and _value_ on that resource.

Each field is a string. Depending on the code, some fields may not
apply. Inapplicable fields are always present, with the empty string
as their value. This simplifies the code that deals with them.


### Server Errors

Server errors are returned as normal 500 responses, which may or may
not have a body. There is no special treatment.


## Using hyperion

Hyperion's API revolves around the idea of a _route_, which is a
combination of:

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

Hyperion provides a basic interface for requesting routes.

```ruby
require 'hyperion'

message_type = 'user'
version = 1
format = :json
route = RestRoute.new(:get, 'http://somesite.org/users/0', ResponseDescriptor.new(message_type, version, format))
user = Hyperion.request(route)
```

You can pass `request` a block, in which case the return value of the
block becomes the return value of `request`.

```ruby
user = Hyperion.request(route) do |result|
  if result.status == HyperionResult::Status::SUCCESS
    User.new(result.body)
  end
end
```

Production-quality error handling becomes hairy quickly, so hyperion
provides a mini DSL to make it easier.

```ruby
Hyperion.request(route) do |result|
  result.when(HyperionResult::Status::SUCCESS) { User.new(result.body) }
  result.when(400..499) { raise 'we screwed up' }
  result.when(500..599) { raise 'they screwed up' }
  result.when(evil) { exit(1) }
end

def evil
  proc do |result|
    result.body['things'].any?{|x| x['id'] == '666'}
  end
end
```

Conditions are tested in order. When hyperion encounters the first
true condition, it executes the associated block, the value of which
becomes the return value of `request`.

A condition may be:

- a `HyperionResult::Status` enumeration member,
- an `ErrorInfo::Code` enumeration member,
- an HTTP code,
- a range of HTTP codes, or
- an arbitrary [predicate](http://en.wikipedia.org/wiki/Predicate_(mathematical_logic)).

To obviate guard logic in predicates, a predicate that raises an
exception is treated as a non-match. In the example above, if the body
didn't have a `'things'` key, then `.any?` would raise a
`NoMethodError`, interpreted as a non-match, and hyperion would move
on to the next predicate.

### Route classes

In practice, you don't want to litter your code with `RestRoute.new`
invocations. Here is a pattern for encapsulating the routes. It is the
client-side analog of `routes.rb` in Rails.

```ruby
class CrudRoutes
  def initialize(resource)
    @resource = resource
  end

  def read(id)
    build(:get, id, response(message_type_for(@resource), 1, :json))
  end

  def create
    build(:post, '', response(message_type_for(@resource), 1, :json), payload(:json))
  end

  ...
end
```

You can easily imagine the rest of the routes and what the helper
methods `build`, `message_type_for`, `response`, and `payload` look like.

Use it like this:

```ruby
user_routes = CrudRoutes.new('users')
Hyperion.request(user_routes.create, body: {name: 'joe', email: 'joe@schmoe.com'})
# later...
joe = Hyperion.request(user_routes.read(joes_id))
```

A few notes:

`CrudRoutes` functions as an API spec, albeit a stripped down one.
Therefore, there is no need to write specs for it; the specs would
likely be harder to understand than the code itself. `CrudRoutes`
could be DRYed up more, but that would reduce its understandability
and create the need for specs.

See `AssaymaticRoutes` in ascent-web for the most complete example to
date.


### Configuration

```ruby
# configure hyperion
Hyperion.configure do |config|
  config.vendor_string = 'indigobio-ascent'  # becomes part of the Accept header
end
```


## Superion

Superion layers more convenience onto Hyperion by helping dispatch the
response: internalizing the response and dealing with errors.

### Render and project

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

On success, the "render" proc has a chance to transform the body
(usually a `Hash`) into an internal representation (often an entity).

After rendering, a "project" proc (the block) has a chance to project
the rendered entity; for example, by choosing a subdocument or field.

```ruby
def user_names
  route = RestRoute.new(:get, "http://somesite.org/users")
  request(route, render: as_users) do |users|
    users.map(&:name)
  end
end
```

### Result dispatch

Superion has four levels of dispatching:

- _core_,
- _includer_, and
- _request_.

<!--- TODO: these terms could use improvement. -->

They are distinguished by their scope. The core handler is built into
superion. An includer handler affects all requests made by a
particular class. A request handler affects only a particular request.

When superion receives a response, it passes the result through the
request, includer, and core handlers, in that order. The first handler
to match wins, and no further handlers are tried. If no handler
matches, then superion raises a `HyperionError` error.

#### Core

The core handler handles the 200 success case and 400- and 500-level
errors. In the success case, the body is rendered and projected. In
the error cases, a `HyperionError` is raised. The message for 400s is
taken from the error response. The message for 500s contains the raw
string body. Specifically for 404, no body is available, so an error
indicating an unimplemented route is raised.


#### Includer

The includer handler is an optional method on the requesting class.

```ruby
class UserGateway
  include Superion

  def find(id)
    ...
  end

  def superion_handler(result)
    result.when(ErrorInfo::MISSING) { raise "The resource was not found: #{result.route}" }
    result.when(HyperionResult::Status::SERVER_ERROR) { ... }
  end
end
```

#### Request

The request handler provides a convenient way to specify a handler as
a `Hash` for an individual `request` call. If a `superion_handler`
looks like:

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

## Testing

Hyperion includes methods to help test your client-side code.

```ruby
require 'hyperion_test'

list_route = RestRoute.new(:get, "http://somesite.org/users")
find_route = RestRoute.new(:get, "http://somesite.org/users/123")

# start a fake server
Hyperion.fake('http://somesite.org') do |svr|
  svr.allow(list_route) { [User.new('123'), User.new('456')].as_json }
  svr.allow(find_route) do |result|
    User.new(result.body['id']).as_json
  end
end

# then place requests against it
users = Hyperion.request(list_route)
expect(users[0]['id']).to eql 123
expect(users[1]['id']).to eql 456
```

`Hyperion::fake` starts a real web server which responds to the
configured routes. It provides an easy way to exercise the entire
stack when running your tests.

For simpler cases:

```ruby
list_route = RestRoute.new(:get, "http://somesite.org/users")
response = [User.new('123'), User.new('456')]
fake_route(list_route, response)
```

See the specs for details.

## Maintenance

When improving hyperion, increment the version in `version.rb` (Hyperion
uses [semantic versioning](http://semver.org)) and describe your
changes in `CHANGES.md`.

## Design decisions

Hyperion is backed by Typhoeus, which in turn is backed by libcurl.
Both are fully featured, have widespread adoption, and are actively
maintained. One particularly nice feature of Typhoeus is that it
provides an easy way to issue multiple requests in parallel, which
is important when you have a microservices architecture.

Our original plan was to have a second gem containing `Hyperion.fake`
and its dependencies. The problem is that you need to keep the two
gems in sync, which reduces agility. As a compromise, `Hyperion.fake`
still lives in the hyperion gem but is only loaded when you `require
'hyperion_test'`. Assuming no production code `require`s
`hyperion_test`, none of the test-related dependencies will be loaded
in a production system, although the gem dependencies will be part of
the production bundle.

# Parking Lot

- Consider making the set of supported formats/content-types extensible.
- Consider adding a configuration value to set the logger to use. If none
  is provided, fall back on Rails.logger, and then a new `Logger`.
