require 'hyperion'
require 'rspec/core'

module TestFrameworkHooks
  def teardown_registered?
    rspec_hooks[:after][:example].to_a.any? do |hook|
      hook.block.source_location == method(:teardown).to_proc.source_location
    end
  end

  def can_hook_teardown?
    RSpec.current_example
  end

  def hook_teardown
    hyperion = self
    rspec_hooks.register(:prepend, :after, :each) { hyperion.teardown }
  end

  def rspec_hooks
    RSpec.current_example.example_group.hooks
  end
end
