require 'hyperion/types/hyperion_result'
require 'hyperion/result_handling/dispatch_dsl'

class Hyperion
  # PW: distinguishing between this and HyperionResult is of
  # dubious value. Consider merging the two.
  class DispatchingHyperionResult < HyperionResult
    include DispatchDsl
  end
end
