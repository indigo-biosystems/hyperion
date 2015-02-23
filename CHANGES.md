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

### 0.0.30
- locked 'contracts' gem to version 0.5 due to possible incompatibility with ascent-web

### 0.0.31
- disabled method contracts due to apparent weirdness
- enable Oj's 'compat' mode to allow writing of both string- and symbol-keyed hashes
- write Time objects to JSON as ISO 8601 (Indigo convention)

### 0.0.32
- Include requested route on response object

### 0.0.33
- Pretty HyperionResult#to_s

### 0.0.34
- HyperionUri (models query params as a hash)
- Fixed logging bug where the logger would capture $stdout the first time it saw it
  and always use that object instead of always using the current value of $stdout.

### 0.0.35
- Canonicalize HyperionUri#to_s output by sorting query param names to make route matching possible.

### 0.0.36
- Pretty ResponseDescriptor#to_s
- When using Hyperion.fake and a rack result is returned, the body is serialized as JSON
  if it is not already a string.
- If parsing JSON fails, just return the unparsed JSON. (For 400s).

### 0.0.37
- Pass the HyperionResult to the `when` block, since it won't always be in lexical scope.

### 0.0.38
- Added superion
- Catch raised errors in handler predicates
- Read 400-level bodies as ClientErrorResponse

### 0.0.39
- Refactored to appease CodeClimate
