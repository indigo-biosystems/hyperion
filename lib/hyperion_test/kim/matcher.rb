class Hyperion
  class Kim
    class Matcher
      # Fancy predicates for HTTP requests.
      # Features:
      # - and/or/not combinators
      # - If a predicate raises an error, it is caught and treated as falsey. simplifies predicates.
      #   For example: headers['Allow'].starts_with?('application/')
      #   will raise if no Allow header was sent, however we really just want to treat that as
      #   a non-match.
      # - Parameter extraction. A matcher can return an augmented Request as the truthy value.

      attr_reader :func

      def initialize(func=nil, &block)
        @func = Matcher.wrap(block || func)
      end

      def call(req)
        @func.call(req)
      end

      def and(other)
        Matcher.new do |req|
          (req2 = @func.call(req)) && other.call(req2)
        end
      end

      def or(other)
        Matcher.new do |req|
          @func.call(req) || other.call(req)
        end
      end

      def not
        Matcher.new do |req|
          @func.call(req) ? nil : req
        end
      end

      def self.and(*ms)
        m, *rest = ms
        if rest.empty?
          m
        else
          m.and(Matcher.and(*rest))
        end
      end

      private

      # Coerce the return value of the function to nil/hash in case
      # it returns a simple true/false.
      # Update (mutate) the request params with any addition values
      # gleaned by a successful match.
      def self.wrap(f)
        if f.is_a?(Matcher)
          f
        else
          proc do |req|
            v = coerce(f, req)
            # Update the request parameters. respond_to?(:merge) is a
            # compromise between outright depending on Kim::Request
            # and threading a totally generic 'update' function
            # through all the matcher code.
            if v && req.respond_to?(:merge)
              req.merge(v)
            else
              v
            end
          end
        end
      end

      def self.coerce(f, req)
        case v = f.call(req)
        when TrueClass then req
        when FalseClass then nil
        else v
        end
      rescue
        nil # treat predicate errors as falsey
      end
    end
  end
end
