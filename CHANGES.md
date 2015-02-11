### 0.0.16
- Hyperion::request can now take a block an easily dispatch on response status, code, or other stuff

### 0.0.17
- If Hyperion.fake allow is passed a route, its block can now return an object instead of a rack-style response.
  The object is serialized according to the route's response descriptor.
- Serialize the POST/PUT payload according to the route's payload descriptor.

### 0.0.18
- Return 404 instead of crashing when headers are the only thing preventing a faked route from matching.

### 0.0.19
- Log stubs and requests for debugging purposes.

### 0.0.20
- Added contracts to some public methods to provide more helpful error messages when passed invalid arguments.

### 0.0.25
- Allow payload descriptor to be nil (for things like DELETE).

### 0.0.26
- Fixed bug with Hyperion fake not defaulting the port to 80

### 0.0.27
- Use Rails.logger if present

### 0.0.28
- Use Rails.logger if present and not nil

### 0.0.29
- Pretty RestRoute.to_s
- Added the ability to match responses on an HTTP code range
