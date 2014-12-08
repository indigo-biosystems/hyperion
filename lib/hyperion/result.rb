require 'hyperion/enum'
require 'immutable_struct'

class Hyperion
  class Result < ImmutableStruct.new(:status, :code, :body)
    module Status
      extend Enum
      TIMED_OUT = 'timed_out'
      NO_RESPONSE = 'no_response'
      CHECK_CODE = 'check_code'
      SUCCESS = 'success'
    end
  end
end