require 'active_support/hash_with_indifferent_access'

class Hyperion
  class Kim
    module Matchers
      # Some useful matchers to include in your code

      def res(resource_pattern)
        regex = resource_pattern.gsub(/:([^\/]+)/, "(?<\\1>[^\\/]+)")
        proc do |req|
          m = req.path.match(regex)
          m && m.names.zip(m.captures).to_h
        end
      end

      def verb(verb_to_match)
        proc do |req|
          req.verb.upcase == verb_to_match.upcase
        end
      end

      def req_headers(required_headers)
        proc do |req|
          required_headers.each_pair.all? do |(k, v)|
            hash_includes?(req.headers.to_h, k, v)
          end
        end
      end

      def req_params(required_params)
        proc do |req|
          required_params.each_pair.all? do |(k, v)|
            hash_includes?(req.params.to_h, k, v)
          end
        end
      end

      private

      def hash_includes?(h, k, v)
        (h.keys.include?(k.to_s) || h.keys.include?(k.to_sym)) && (v.nil? || (h[k.to_s] || h[k.to_sym]) == v)
      end

      extend self
    end
  end
end
