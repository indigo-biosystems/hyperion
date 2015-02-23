require 'immutable_struct'
# Hyperion::Util.require_recursive '.' #TODO: extract the requiring into utils or someplace

# require 'contracts'
# require 'hyperion/contracts'
# include Contracts
# include Hyperion::Contracts

Dir.glob(File.join(File.dirname(__FILE__), 'hyperion/**/*.rb')).each{|path| require_relative(path)}
require 'typhoeus'
require 'oj'
require 'continuation'
require 'abstractivator/proc_ext'
require 'abstractivator/enumerable_ext'
require 'active_support/core_ext/object/blank'
