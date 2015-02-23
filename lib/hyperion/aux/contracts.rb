require 'contracts'

class Hyperion
  module Contracts
    class ValidEnum < ::Contracts::CallableClass
      def initialize(enum_module)
        @enum = enum_module
      end

      def valid?(x)
        @enum.values.include?(x)
      end

      def to_s
        "a member of the #{@enum.name} enumeration"
      end
    end
  end
end
