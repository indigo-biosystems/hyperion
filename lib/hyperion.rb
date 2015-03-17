# hyperion's dependencies
require 'immutable_struct'
require 'typhoeus'
require 'oj'
require 'continuation'
require 'abstractivator/proc_ext'
require 'abstractivator/enumerable_ext'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/module/attribute_accessors'

# ensure the requirer gets everything (except hyperion_test)
require 'hyperion/hyperion'
require 'hyperion/requestor'
Dir.glob(File.join(File.dirname(__FILE__), 'hyperion/types/**/*.rb')).each { |path| require_relative(path) }
