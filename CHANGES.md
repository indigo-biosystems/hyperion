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

### 0.0.40
- Moved mimic back to being a runtime dependency

### 0.0.41
- Fixed ClientErrorResponse#from_attrs

### 0.0.42
- Made ClientErrorResponse constructor interface less error-prone
- Always read client error response as JSON

### 0.0.43
- Raise an error if superion response falls through and no superion_fallthrough method is defined.

### 0.0.44
- Fixed "require" problems

### 0.0.45
- Support query params that are arrays

### 0.0.46
- Allow query to be nil (bugfix)

### 0.0.47
- Fixed slow POSTs > 1KB

### 0.0.48
- Fixed bug where superion's interface was too loose
- Do not require dispatch predicates to take an argument
- Log when requests complete

### 0.0.50
- Allow dispatching on client error code

### 0.0.52
- `ErrorInfo` -> `ClientErrorDetail`
- `ErrorInfo::Code` -> `ClientErrorCode`
- `HyperionResult::Status` -> `HyperionStatus`
- `ClientErrorResponse.new` signature changed
- superion was absorbed into hyperion. instead, `require 'hyperion'`
  and `include Hyperion::Requestor`
- `superion_handler` -> `hyperion_handler`
- removed `superion_fallthrough`. it's only hit on 100s and 300s.
  Custom handlers can already handle those if they want. An error is
  raised if a 100 or 300 falls through.
- removed `Superion.missing`

### 0.0.53
- Fixed bug due to missing `require`

### 0.0.54
- abstractivator 0.0.27

### 0.0.55
- upgraded abstractivator for wrapped enum values

### 0.0.56
- another enum tweak

### 0.0.57
- json enum support from abstractivator

### 0.0.58
- Renamed `ClientErrorResponse#body` -> `ClientErrorResponse#content`
