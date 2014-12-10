class Hyperion
  class Util
    def self.require_recursive(basepath)
      Dir.glob(File.join(File.dirname(__FILE__), "#{basepath}/**/*.rb")).each{|path| require_relative(path)}
    end
  end
end
