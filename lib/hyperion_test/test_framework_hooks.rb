require 'hyperion'
require 'rspec/core'

module TestFrameworkHooks
  def reset_registered?
    rspec_after_example_hooks.any? do |hook_proc|
      hook_proc.source_location == method(:reset).to_proc.source_location
    end
  end

  def can_hook_reset?
    !!RSpec.current_example
  end

  def hook_reset
    hyperion = self
    rspec_hooks.register(:prepend, :after, :each) { hyperion.reset }
  end

  def rspec_after_example_hooks
    if rspec_hooks.respond_to?(:[]) # approximately rspec 3.1.0
      rspec_hooks[:after][:example].to_a.map(&:block)
    else # approximately rspec 3.3.0
      default_if_no_hooks = nil
      hook_collection = rspec_hooks.send(:hooks_for, :after, :example) {default_if_no_hooks}
      return [] unless hook_collection
      hook_collection.items_and_filters.map(&:first).map(&:block)
    end
  end

  def rspec_hooks
    RSpec.current_example.example_group.hooks
  end
end
