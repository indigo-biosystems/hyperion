require 'oj'
require 'stringio'
require 'hyperion/aux/logger'
require 'abstractivator/enum'

class Hyperion
  module Formats
    # Serializes and deserializes the supported formats.
    # This is done as gracefully as possible.

    include Hyperion::Logger

    define_enum :Known, :json, :protobuf

    def write(obj, format)
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
      begin
        TimeAsJsonShim.hyperion_mode = true
        Oj.dump(obj, mode: :compat)
      ensure
        TimeAsJsonShim.hyperion_mode = false
      end
    end

    def read_json(bytes)
      begin
        Oj.compat_load(bytes, mode: :compat)
      rescue Oj::ParseError => e
        logger.error e.message
        bytes
      end
    end

    def get_oj_line_and_col(e)
      m = e.message.match(/at line (?<line>\d+), column (?<col>\d+)/)
      m ? [m[:line].to_i, m[:col].to_i] : nil
    end
  end
end

module TimeAsJsonShim
  mattr_accessor :hyperion_mode

  def as_json(*)
    if TimeAsJsonShim.hyperion_mode
      self.utc.iso8601(3)
    elsif defined? super
      super
    else
      to_s
    end
  end
end

class Time
  include TimeAsJsonShim
end
