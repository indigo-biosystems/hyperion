class Hyperion
  class Kim
    class Matcher
      # Fancy predicates for HTTP requests.
      # Features:
      # - and/or/not combinators
      # - nil/hash falsiness/truthiness allows additional parameters to be extracted during matching
      #   (e.g., '/people/:name')
      # - predicates can see parameters extracted by previous predicates. allows for matchers like:
      #   route('/people/:name').and(person_is_superdouche)
      # - if a predicate raises an error, it is caught and treated as falsey. simplifies predicates.
      #   For example: headers['Allow'].starts_with?('application/')
      #   will raise if no Allow header was sent, however we really just want to treat that as
      #   a non-match.

      attr_reader :func

      def initialize(func=nil, &block)
        @func = Matcher.wrap(block || func)
      end

      def call(req)
        @func.call(req)
      end

      def and(other)
        Matcher.new do |req|
          a = @func.call(req)
          b = other.call(req)
          a && b ? a.merge(b) : nil
        end
      end

      def or(other)
        Matcher.new do |x|
          a = @func.call(x)
          b = other.call(x)
          a || b ? (a || {}).merge(b || {}) : nil
        end
      end

      def not
        Matcher.new do |x|
          a = @func.call(x)
          a ? nil : {}
        end
      end

      def self.and(*ms)
        h, *t = ms
        if t.empty?
          h
        else
          h.and(Matcher.and(*t))
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
          v = coerce { f.call(req) }
          # Update the request parameters. respond_to?(:params) is a
          # compromise between outright depending on Kim::Request
          # and threading a totally generic 'update' function
          # through all the matcher code.
          req.params = OpenStruct.new(req.params.to_h.merge(v)) if v && req.respond_to?(:params)
          v
        end
      end
      end

      def self.coerce
        v = yield
        case v
        when TrueClass then {}
        when FalseClass then nil
        else v
        end
      rescue
        nil # treat predicate errors as falsey
      end
    end
  end
end
