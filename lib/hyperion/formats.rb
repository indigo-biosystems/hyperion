require 'oj'
require 'stringio'
require 'hyperion/aux/logger'
require 'abstractivator/enum'
require 'hyperion/types/multipart'

class Hyperion
  module Formats
    # Serializes and deserializes the supported formats.
    # This is done as gracefully as possible.

    include Hyperion::Logger

    define_enum :Known, :json, :protobuf

    def write(obj, format)
      return obj.body if obj.is_a?(Multipart)
      return obj if obj.is_a?(String) || obj.nil? || format.nil?

      case Formats.get_from(format)
      when :json; write_json(obj)
      when :protobuf; obj
      else; fail "Unsupported format: #{format}"
      end
    end

    def read(bytes, format)
      return nil if bytes.nil?
      return bytes if format.nil?

      case Formats.get_from(format)
      when :json; read_json(bytes)
      when :protobuf; bytes
      else; fail "Unsupported format: #{format}"
      end
    end

    def self.get_from(x)
      x.respond_to?(:format) ? x.format : x
    end

    private

    def write_json(obj)
      Oj.dump(obj, oj_options)
    end

    def read_json(bytes)
      begin
        Oj.compat_load(bytes, oj_options)
      rescue Oj::ParseError => e
        logger.error e.message
        bytes
      end
    end

    def oj_options
      {
          mode: :compat,
          time_format: :xmlschema,  # xmlschema == iso8601
          use_to_json: false,
          second_precision: 3,
          bigdecimal_load: :float
      }
    end

    def get_oj_line_and_col(e)
      m = e.message.match(/at line (?<line>\d+), column (?<col>\d+)/)
      m ? [m[:line].to_i, m[:col].to_i] : nil
    end
  end
end
