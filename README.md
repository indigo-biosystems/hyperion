# Hyperion

Hyperion is a REST client that follows certain conventions layered on top of HTTP.

It revolves around the idea of a _route_, which is a combination of:
- HTTP method
- URI
- parameters that influence header generation and de/serialization
  - ResponseDescriptor (what kind of data do we want back)
    - influences the 'Accept' header
  - PayloadDescriptor (what kind of data is being PUT or POSTed)
    - influences the 'Content-Type' header

Due to the prevalence of routes, the API may feel heavyweight if you use
it for unintended purposes. For instance, you may expect to be able to call

```ruby
Hyperion.get('http://somesite.org/users/0')
```

You cannot. The closest equivalent would be

```ruby
Hyperion.request(RestRoute(:get, 'http://somesite.org/users/0', ResponseDescriptor.new('user', 1, :json)))
```

But in practice, you almost always have a route in hand already:

```ruby
Hyperion.request(route)
# or perhaps
Hyperion.request(AssaymaticRoutes.find_by_name('CompUDS'))
```

Nice.

# Testing

Hyperion also provides methods that make it trivial to spin up fake servers for testing purposes.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hyperion'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hyperion

