require 'oj'

class Hyperion
  module Formats
    def write(obj, format)
      return obj if obj.is_a?(String)
      case format
        when :json; Oj.dump(obj)
        when :protobuf; obj
        else; raise "Unsupported format: #{format}"
      end
    end

    def read(bytes, format)
      return nil if bytes.nil?
      case format
        when :json; read_json(bytes)
        when :protobuf; bytes
        else; raise "Unsupported format: #{format}"
      end
    end

    private

    def read_json(bytes)
      begin
        Oj.load(bytes)
      rescue Oj::ParseError => e
        line, col = get_oj_line_and_col(e)
        if line
          raise "#{e.message} : #{bytes.lines[line-1]}"
        else
          raise
        end
      end
    end

    def get_oj_line_and_col(e)
      m = e.message.match(/at line (?<line>\d+), column (?<col>\d+)/)
      m ? [m[:line].to_i, m[:col].to_i] : nil
    end

  end
end
