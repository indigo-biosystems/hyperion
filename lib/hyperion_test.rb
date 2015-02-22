require 'hyperion'
Dir.glob(File.join(File.dirname(__FILE__), 'hyperion_test/**/*.rb')).each{|path| require_relative(path)}
