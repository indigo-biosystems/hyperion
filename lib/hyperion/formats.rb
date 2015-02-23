require 'oj'
require 'hyperion'
require 'stringio'
require 'hyperion/aux/logger'
require 'abstractivator/enum'

class Hyperion
  module Formats
    include Hyperion::Logger

    module Known
      include Enum
      JSON = :json
      PROTOBUF = :protobuf
    end

    def write(obj, format)
      return obj if obj.is_a?(String) || obj.nil?
      return obj if format.nil?

      case Formats.get_from(format)
        when :json; write_json(obj)
        when :protobuf; obj
        else; raise "Unsupported format: #{format}"
      end
    end

    def read(bytes, format_or_descriptor)
      return nil if bytes.nil?
      return bytes if format_or_descriptor.nil?

      case Formats.get_from(format_or_descriptor)
        when :json; read_json(bytes)
        when :protobuf; bytes
        else; raise "Unsupported format: #{format_or_descriptor}"
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
  class << self
    attr_accessor :hyperion_mode
  end

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
