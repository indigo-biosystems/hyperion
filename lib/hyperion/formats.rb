require 'oj'

class Hyperion
  module Formats
    def write(obj, format)
      case format
        when :json; Oj.dump(obj)
        else; raise "Unsupported format: #{format}"
      end
    end

    def read(bytes, format)
      case format
        when :json; Oj.load(bytes)
        else; raise "Unsupported format: #{format}"
      end
    end
  end
end