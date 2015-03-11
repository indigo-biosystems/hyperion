require 'hyperion/types/hyperion_result'
require 'hyperion/result_handling/dispatch_dsl'

class Hyperion
  class DispatchingHyperionResult < HyperionResult
    include DispatchDsl
  end
end
