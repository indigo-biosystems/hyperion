## [0.1.7](https://github.com/indigobio/hyperion/compare/v0.1.6...indigobio:v0.1.7) (2015-12-14)

- fake_route now works with multipart body
  ([6e1e7d3](https://github.com/indigobio/hyperion/commit/6e1e7d3c4db6e284522ed468adbac1fecd8fcb91))


## [0.1.6](https://github.com/indigobio/hyperion/compare/v0.1.5...indigobio:v0.1.6) (2015-11-16)

- added form data support
  ([68f8ef0](https://github.com/indigobio/hyperion/commit/68f8ef0258da941b2cdf6b4e12081d8c979be50a))


## [0.1.5](https://github.com/indigobio/hyperion/compare/v0.1.4...indigobio:v0.1.5) (2015-11-13)

- Propagate logatron headers
  ([03c8fc8](https://github.com/indigobio/hyperion/commit/03c8fc8df0c40a2008a13496036d2e9aa741e7ba))
- Use logatron
  ([5f9182f](https://github.com/indigobio/hyperion/commit/5f9182f875c396d73e5c3e412a424946ad7c5d99))
- Restrict Oj from loading decimal numbers as BigDecimal
  ([56537a6](https://github.com/indigobio/hyperion/commit/56537a6054691e5e89397fbc860159e08485a479))


## [0.1.4](https://github.com/indigobio/hyperion/compare/v0.1.3...indigobio:v0.1.4) (2015-11-11)

- Added a spec in superion for passing headers into the belly of the beast
  ([dd01c70](https://github.com/indigobio/hyperion/commit/dd01c70dc72f90302121da7416930734a71be249))
- Passthrough of headers
  ([a49851b](https://github.com/indigobio/hyperion/commit/a49851b67146fa31730a2109e332dd19152b946b))


## [0.1.3](https://github.com/indigobio/hyperion/compare/v0.1.2...indigobio:v0.1.3) (2015-11-02)

- Expect header causes problems on AWS. Found a better way to disable the header.
  ([7949c98](https://github.com/indigobio/hyperion/commit/7949c98c962c05616e91afa10b153f4153a2c95c))
- Renamed gem to hyperion_http
  ([0fab86b](https://github.com/indigobio/hyperion/commit/0fab86bc92fc7d279ce5b2ca32d5f2cad5261f4e))


## [0.1.2](https://github.com/indigobio/hyperion/compare/ddb7f399f4fd18c3e1fee07495bb082da9b6f2ff...indigobio:v0.1.2) (2015-10-14)

- Attempted to solve problem in tests where clients hit an old server
  ([420f017](https://github.com/indigobio/hyperion/commit/420f017b1d2e1dcd39f313982fe713c29d7ff3a9))
- Updated gems. Hyperion.fake supports up to RSpec 3.3 now.
  ([d82184a](https://github.com/indigobio/hyperion/commit/d82184a95ae6a3b85d37ee8db49487f4a417aea5))
- Changed require for rspec to use rspec/core
  ([4e29d43](https://github.com/indigobio/hyperion/commit/4e29d431d58375487a27a947e745adaba12566c1))
- Added RspecJunitFormatter gem as development dependency
  ([b8a8d34](https://github.com/indigobio/hyperion/commit/b8a8d34c8d16c056f3873ee615ca82311586eb0d))
- Fixed Time object in tests to have specified timezone
  ([aec7305](https://github.com/indigobio/hyperion/commit/aec73059941eae3ff59289b5592f94eeb9198b33))
- Fixed timezone representation in tests
  ([de8f2fa](https://github.com/indigobio/hyperion/commit/de8f2faba7fbb046975d8c65a02d9bbd0b21d7c1))
- Improved Errors section
  ([b116b26](https://github.com/indigobio/hyperion/commit/b116b26080d73eee0f16262aa3bdd4b47c86e715))
- Added Maintenance section
  ([5ffaf31](https://github.com/indigobio/hyperion/commit/5ffaf31b0b06aafbad1470ec867dd8927e290a3d))
- Filled out Versioning section
  ([5dd0fc2](https://github.com/indigobio/hyperion/commit/5dd0fc2b2f3387bfb725777eef1a28e628f170e9))
- Whitelisted branches in travisCI config
  ([a1c9eab](https://github.com/indigobio/hyperion/commit/a1c9eab54d6043fec681b5af0905aba7f2251e4b))
- Fixed tests failing on TravisCI
  ([ca26e20](https://github.com/indigobio/hyperion/commit/ca26e206ccf7bc155f63e2c10875aec4b80d36a8))
- constraint rspec version
  ([439d01e](https://github.com/indigobio/hyperion/commit/439d01eaf2d89375bc12fdbaa31253b3d45efc98))
- Default rake task runs rspec
  ([da171c5](https://github.com/indigobio/hyperion/commit/da171c59a75a071cf00eb50af18456677d26b3ae))
- TravisCI integration
  ([3ed1637](https://github.com/indigobio/hyperion/commit/3ed16378c4db1dff742c7e63c2995838fcfb3625))
- Renamed `ClientErrorResponse#body` -> `ClientErrorResponse#content`
  ([8e95ddf](https://github.com/indigobio/hyperion/commit/8e95ddf4a02909ee2eda7349c3f8ee28db9cb8de))
- json enum support from abstractivator
  ([2140f6f](https://github.com/indigobio/hyperion/commit/2140f6fb5c1fa544b41c819e624ae01916ce2642))
- another enum tweak
  ([470fd2e](https://github.com/indigobio/hyperion/commit/470fd2ed9146d5bb0bf639df308bfa711cf324fc))
- upgraded abstractivator for wrapped enum values
  ([39b934f](https://github.com/indigobio/hyperion/commit/39b934f0f83904cc7174e4f3f4cef63c9c9b9d57))
- abstractivator 0.0.27
  ([97a00b2](https://github.com/indigobio/hyperion/commit/97a00b24f770e2bcf55ca6cc9f7e78d6f4318286))
- Fixed bug due to missing `require`
  ([102cbcb](https://github.com/indigobio/hyperion/commit/102cbcb10aa33c1d5f379b04e95304ef9860205e))
- Removed Superion.missing
  ([f565d5f](https://github.com/indigobio/hyperion/commit/f565d5f8f834f695911af8d78a037fdb99ab9602))
- Removed hyperion_fallthrough
  ([14354ce](https://github.com/indigobio/hyperion/commit/14354cec924709fc1481a5e617b77aa813cdeb89))
- Renamed Superion -> Hyperion::Requestor
  ([e9c4e15](https://github.com/indigobio/hyperion/commit/e9c4e153aa9dcba8f388b47d91da199148001c7c))
- Added to readme
  ([88b732c](https://github.com/indigobio/hyperion/commit/88b732cc9150b97711804adc76032ab9d696b8b1))
- Use Oj's time formatting facilities, rather than a hack.
  ([4a8ef9e](https://github.com/indigobio/hyperion/commit/4a8ef9e63f2d79f6e24c9e75cb5f65c17955889a))
- Added doc comments
  ([4445689](https://github.com/indigobio/hyperion/commit/44456894e62acc1aa514b8ddf08ed26b7cd2dfe9))
- README tweaks
  ([24a19b1](https://github.com/indigobio/hyperion/commit/24a19b11f8e5bad135e087bd2c93ce9b8178b885))
- More README additions
  ([7c79296](https://github.com/indigobio/hyperion/commit/7c7929620d6f22a9fd952631fa976149eaedae45))
- First stab at README
  ([6b1833b](https://github.com/indigobio/hyperion/commit/6b1833b54b4ae8d2ad23674ccd166c0edf2e7e85))
- Factored out the vendor string
  ([bfc4d8c](https://github.com/indigobio/hyperion/commit/bfc4d8c18b6c897e7e5945d7ca93ad03fbb3ed2c))
- Cleaned up Hyperion::fake code
  ([ab9431a](https://github.com/indigobio/hyperion/commit/ab9431a7aff88ebd3f5cbde9fc256287f5259fec))
- tweak
  ([9a32738](https://github.com/indigobio/hyperion/commit/9a32738da123efe1589f996a587f69012836e2b3))
- reinstated superion specs
  ([17ea2a8](https://github.com/indigobio/hyperion/commit/17ea2a8d8fa1877e992039e2efb7622105a73e94))
- Allow dispatching on client error code
  ([41fa215](https://github.com/indigobio/hyperion/commit/41fa2150becd2891fa7bcc381fc76169ecc670db))
- Cleaned up error raising. Moved superion code into lib/hyperion
  ([05725aa](https://github.com/indigobio/hyperion/commit/05725aae1e7a9d4f1c355c9e3766982f59a6b594))
- Switch to new style enums
  ([c9225f1](https://github.com/indigobio/hyperion/commit/c9225f1347f4a5cb6204266e72aa22209715862c))
- Upgraded abstractivator. Fixed failing spec due to Oj behavior change.
  ([aed6f12](https://github.com/indigobio/hyperion/commit/aed6f12026c1087e2e6b3c78aea6548899911fc5))
- Log when requests complete
  ([812b71e](https://github.com/indigobio/hyperion/commit/812b71ea59525a8bf882c3b07eaeb81f916ad510))
- Do not require dispatch predicates to take an argument
  ([1ab265b](https://github.com/indigobio/hyperion/commit/1ab265ba4052af924829933057640878e354b49f))
- Code cleanup
  ([a92e6d3](https://github.com/indigobio/hyperion/commit/a92e6d30f9a25a54f5d0839c99662b6bc7a479be))
- Fixed bug where superion's interface was too loose
  ([806d280](https://github.com/indigobio/hyperion/commit/806d280ea0d7b6e089c2aeeace551696666d6df8))
- Fixed slow POSTs > 1KB
  ([53db42b](https://github.com/indigobio/hyperion/commit/53db42b05ff51f82f7ea9c3ba475c8023e38d007))
- Allow query to be nil (bugfix)
  ([b9c6df5](https://github.com/indigobio/hyperion/commit/b9c6df55d7143df943ce8ac0a021fcece065904e))
- 0.0.45
  ([a1fe768](https://github.com/indigobio/hyperion/commit/a1fe7688008c6b8f65921c6024637238e28781ec))
- Cleaned up HyperionUri
  ([0268c97](https://github.com/indigobio/hyperion/commit/0268c97c6d65627e7c4d39e3d6a2dc682e822f0e))
- Support query params that are arrays
  ([c7e5e00](https://github.com/indigobio/hyperion/commit/c7e5e0057d529a989eac80f2e13e5d20db3e5548))
- Added ci.sh
  ([af6bd5b](https://github.com/indigobio/hyperion/commit/af6bd5be9fea93fbe5322ee44176ce03ec39aad2))
- Fixed "require" problems
  ([d54b13c](https://github.com/indigobio/hyperion/commit/d54b13c5a7352398d8460dd6942d8344ecaddc9b))
- Raise an error if superion response falls through and no superion_fallthrough method is defined.
  ([d46d84a](https://github.com/indigobio/hyperion/commit/d46d84acd4341b0b5ac9993d0ac6b6fb3484983a))
- Always read client error response as JSON
  ([c043a9e](https://github.com/indigobio/hyperion/commit/c043a9ec75df7ac4330566158044fbec9d5b2e9d))
- Made ClientErrorResponse constructor interface less error-prone
  ([19eaadd](https://github.com/indigobio/hyperion/commit/19eaadde9e541194d1ec0f3b938d2aa09895831d))
- Fixed ClientErrorResponse#from_attrs
  ([0f79140](https://github.com/indigobio/hyperion/commit/0f79140acee6c7c4d8ab5c1902b0acdb129a0970))
- Moved mimic back to being a runtime dependency
  ([36feba4](https://github.com/indigobio/hyperion/commit/36feba4dc9c25ddf3610629e0ac9c3429838f155))
- Refactored to appease CodeClimate
  ([465e7cc](https://github.com/indigobio/hyperion/commit/465e7cc1c24b497fe10caa44be72794ce4bd2582))
- Read 400-level bodies as ClientErrorResponse
  ([9447159](https://github.com/indigobio/hyperion/commit/94471595a3fb2944e8b1ffaafb0700d71bc413e1))
- Catch raised errors in handler predicates
  ([506d06b](https://github.com/indigobio/hyperion/commit/506d06b42da41bebfd164cd2682918a8bd97dcd5))
- Added superion
  ([5ed8757](https://github.com/indigobio/hyperion/commit/5ed8757f26749f88dd4e6f7de217bbf7fb6d9bee))
- Pass the HyperionResult to the block, since it won't always be in lexical scope.
  ([2370e54](https://github.com/indigobio/hyperion/commit/2370e54e83135acfd35edbdfb5947eeb3e74232e))
- If parsing JSON fails, just return the unparsed JSON.
  ([2b41d2f](https://github.com/indigobio/hyperion/commit/2b41d2fdce0c7bd821d32397028fe22db5356b7b))
- Hyperion.fake: try to serialize body of rack results
  ([ab38b77](https://github.com/indigobio/hyperion/commit/ab38b77a7170d3a652dcb553f4d21c8e90127289))
- Pretty ResponseDescriptor#to_s
  ([f2f28d9](https://github.com/indigobio/hyperion/commit/f2f28d9812372c69566479d5c84d4ad83cdfe215))
- Canonicalize HyperionUri#to_s output by sorting query param names to make route matching possible.
  ([002f7e8](https://github.com/indigobio/hyperion/commit/002f7e81972a20e84d8bd9877d7d189e5148b28a))
- Fixed logging bug where the logger would capture the first time it saw it.
  ([e7e267a](https://github.com/indigobio/hyperion/commit/e7e267a40ef9e2f68cc7aa3eb2ff8f307ed8743b))
- HyperionUri (models query params as a hash)
  ([7d552b9](https://github.com/indigobio/hyperion/commit/7d552b9221c904382d1205a82f5b085e8290196c))
- Pretty HyperionResult#to_s
  ([a8f6cfa](https://github.com/indigobio/hyperion/commit/a8f6cfac9c76c0595f4f518f1798da3486477344))
- Include requested route on response object
  ([a0fcc4c](https://github.com/indigobio/hyperion/commit/a0fcc4c6b088879f74be151dd621115b78415e59))
- JSON writing fixes
  ([c1de890](https://github.com/indigobio/hyperion/commit/c1de890960ad0006a6f3b64a365e88804b4a19a3))
- Added the ability to match responses on an HTTP code range
  ([ee93c51](https://github.com/indigobio/hyperion/commit/ee93c51a84029f43ca703e501954bd57c32d5efe))
- Friendly RestRoute#to_s
  ([e3db641](https://github.com/indigobio/hyperion/commit/e3db6415bc64aa2f33997caa9e7c8b8d765293ec))
- Tolerate Railes.logger == nil
  ([40a8ceb](https://github.com/indigobio/hyperion/commit/40a8cebd3a77aafcbf2479b8eb2ce3c2581d3e55))
- Use Rails.logger if present
  ([b209b8b](https://github.com/indigobio/hyperion/commit/b209b8b44e83026dd438f2d796c049925c849681))
- Removed unnecessary shared examples from tests
  ([f337522](https://github.com/indigobio/hyperion/commit/f3375222ecbf7732da19ffa75f9223d45de1e68f))
- Fixed bug with Hyperion fake not defaulting the port to 80
  ([0a33d52](https://github.com/indigobio/hyperion/commit/0a33d5216c964d81cd46f64af0e105309d7014d5))
- Allow payload descriptor to be nil (for things like DELETE)
  ([12dd4bf](https://github.com/indigobio/hyperion/commit/12dd4bf02c436652798130042d45249930f36c8d))
- fixed contract
  ([8ddfdaa](https://github.com/indigobio/hyperion/commit/8ddfdaa3565ac478413dac94abad7e39ca1e33b6))
- fixed contract
  ([fdccd0a](https://github.com/indigobio/hyperion/commit/fdccd0a84d754f4ef70ab12b539f0a47e7561c54))
- fixed contract
  ([4afa67f](https://github.com/indigobio/hyperion/commit/4afa67f706fafcce9ff9f745c016ef1edc143bc1))
- fixed bug
  ([6403cd7](https://github.com/indigobio/hyperion/commit/6403cd78cbceadea233c1db46a08cb54c1cea30f))
- Added some method contracts
  ([1c52054](https://github.com/indigobio/hyperion/commit/1c52054ec5fc386b7c461556de8552a4a3508dbb))
- Log stubs and requests for debugging purposes.
  ([18647ac](https://github.com/indigobio/hyperion/commit/18647acc0168e273a13170aafd202b189b901b15))
- Return 404 instead of crashing when headers are the only thing preventing a faked route from matching.
  ([9e7af87](https://github.com/indigobio/hyperion/commit/9e7af8764f08b9f3606d3ec17d92e326c5bc6450))
- Serialize the POST/PUT payload according to the route's payload descriptor.
  ([7652e5a](https://github.com/indigobio/hyperion/commit/7652e5a072b9ec5eafd19f75dae7893c65302b1e))
- If Hyperion.fake allow is passed a route, its block can now return an object instead of a rack-style response.
  ([47f2b1e](https://github.com/indigobio/hyperion/commit/47f2b1ec65ebed3413b7fc9af21802fd169dc4e4))
- Hyperion::request now takes a block for dispatching on response properties.
  ([86328c7](https://github.com/indigobio/hyperion/commit/86328c7dc4604b2713b089b1bb9bd489a4886ea9))
- Improved documentation; monkeypatched some methods onto URI
  ([c106480](https://github.com/indigobio/hyperion/commit/c106480992f598adad8e32cb86514f1640ac55c2))
- Print to stdout when a request is redirected due to a stub/fake
  ([be05c3f](https://github.com/indigobio/hyperion/commit/be05c3f966aecaac80ee9dfeb9f7afb9c17afec4))
- Refactored
  ([7ca0f4d](https://github.com/indigobio/hyperion/commit/7ca0f4de4b4416d923d4a2f13f0c0da8c64a507b))
- bump
  ([905815e](https://github.com/indigobio/hyperion/commit/905815e0f6c2c20967d9004bf1d68d375eda9046))
- fixed bug
  ([4081fcf](https://github.com/indigobio/hyperion/commit/4081fcf746f318cd20c1154fbc16ad3fed888c06))
- Removed RestRoute.path; uri is now a URI object. Hyperion.fake's allow() now takes routes too
  ([6bc1aff](https://github.com/indigobio/hyperion/commit/6bc1affe378e18567775508c5224b79a08e65ebd))
- Added PUT and DELETE
  ([3a11fee](https://github.com/indigobio/hyperion/commit/3a11fee5386e02a3f9807a1c48b250fbc789fc0c))
- Removed hyperion/util.rb
  ([096ba85](https://github.com/indigobio/hyperion/commit/096ba8514d4c0561cc8a4f534d335711786b8d63))
- Hyperion::fake can be called multiple times to add new routes
  ([52398cb](https://github.com/indigobio/hyperion/commit/52398cbee465f6f9cd94d60d6f880fd7c0c4f257))
- Added Hyperion::request
  ([31ccb42](https://github.com/indigobio/hyperion/commit/31ccb42ab7a758c883e902e54907e86e28185968))
- Hyperion::ResponseParams => ResponseParams
  ([dbedbf4](https://github.com/indigobio/hyperion/commit/dbedbf4906aa97c0973d688da8548c8295f586b4))
- Don't try to hook RSpec when RSpec is not being used
  ([2da102a](https://github.com/indigobio/hyperion/commit/2da102ae8bd6bcd24e9b3a4d1744800d40e1abea))
- Fake now cleans up after itself in all groups
  ([5d66fb2](https://github.com/indigobio/hyperion/commit/5d66fb246e21d9bb187303e85663f84409180a5b))
- Fixed header comparison for Hyperion::fake
  ([530df29](https://github.com/indigobio/hyperion/commit/530df295310688ddbb944b503dd5c04ab2777bf8))
- Hyperion.fake now cleans up after itself automagically
  ([5ae95d7](https://github.com/indigobio/hyperion/commit/5ae95d74e4f9fe65fd6f2b9f396b90bac0a5102a))
- Made private Hyperion::Test methods actually private
  ([63ebe87](https://github.com/indigobio/hyperion/commit/63ebe87c0603019f3c070ac715026972c6fc79ef))
- Hyperion::fake now passes tests
  ([b3a18ad](https://github.com/indigobio/hyperion/commit/b3a18ad4de2bc876f8d5ba9e9aa9c973f8486876))
- Fixed broken other tests
  ([06ac677](https://github.com/indigobio/hyperion/commit/06ac6779a3ca6e02660abdd88fafce95100142e0))
- wip
  ([9858b28](https://github.com/indigobio/hyperion/commit/9858b28e8c95b35f2984a9325cc6e1a66a6926d9))
- Fixed gemspec dependencies
  ([585b3d1](https://github.com/indigobio/hyperion/commit/585b3d1b25c8a4821362f2932944e296b2865415))


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

### 0.0.55
- upgraded abstractivator for wrapped enum values

### 0.0.56
- another enum tweak

### 0.0.57
- json enum support from abstractivator

### 0.0.58
- Renamed `ClientErrorResponse#body` -> `ClientErrorResponse#content`

### 0.1.0

### 0.1.1
- Attempted to solve problem in tests where clients hit an old server while
  it's shutting down, resulting in a timeout.

### 0.1.2 - 2015-10-14
- Fixed broken gemspec version for abstractivator

### 0.1.3 - 2015-11-2
- Changed name of the gem to `hyperion_http`
- Fixed bug with Expect headers on AWS

### 0.1.4 - 2015-11-11
- Added support for additional headers for a request
 
### 0.1.5 - 2015-11-13
- Added logatron headers to requests

### 0.1.6 - 2015-11-16
- Added `Multipart` body

### 0.1.7 - 2015-12-14
- Fixed `fake_route` to work with a multipart body

### Unreleased
- Improved logging of error responses and headers