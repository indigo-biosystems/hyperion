require 'uri'
require 'delegate'
require 'active_support/core_ext/hash/keys'
require 'rack/utils'
require 'abstractivator/array_ext'

class HyperionUri < SimpleDelegator
  # An enhanced version of URI. Namely,
  # - the base uri is a first class citizen,
  # - it accepts a hash containing query key/values, and
  # - it form-encodes query values that are arrays.

  attr_accessor :query_hash

  def initialize(uri, query_hash={})
    @uri = make_ruby_uri(uri)
    query_from_uri = parse_query(@uri.query)
    additional_query_params = validate_query(query_hash)
    @query_hash = query_from_uri.merge(additional_query_params)
    __setobj__(@uri)
  end

  def query
    query_string(@query_hash)
  end

  def query=(query)
    @query_hash = parse_query(query)
  end

  def path
    path = @uri.path || ''
    path == '' ? '/' : path
  end

  def to_s
    fixed = @uri.dup
    fixed.query = query
    make_ruby_uri(fixed).to_s
  end

  def inspect
    "#<HyperionUri:0x#{(object_id << 1).to_s(16)} #{to_s}>"
  end

  # @return [String] the URI base e.g., "h\ttp://somehost:80"
  def base
    "#{scheme}://#{host}:#{port}"
  end

  def base=(uri)
    uri = uri.is_a?(HyperionUri) ? uri : HyperionUri.new(uri)
    self.scheme = uri.scheme
    self.host = uri.host
    self.port = uri.port
  end

  private

  def validate_query(query)
    query ||= {}
    query.is_a?(Hash) or fail 'query must be a hash'
    query.values.all?(&method(:simple_value?)) or fail 'query values must be simple'
    query.stringify_keys
  end

  def simple_value?(x)
    case x
      when Array; x.all?(&method(:primitive_value?))
      else; primitive_value?(x)
    end
  end

  def primitive_value?(x)
    x.is_a?(String) || x.is_a?(Numeric) || x.is_a?(Symbol)
  end

  def parse_query(query)
    query ||= ''
    Rack::Utils.parse_nested_query(query)
  end

  def query_string(query_hash)
    return nil if query_hash == {}
    sorted = query_hash.map{|(k, v)| [k.to_s, stringify(v)]}.sort_by(&:key).to_h
    Rack::Utils.build_nested_query(sorted)
  end

  def stringify(x)
    x.is_a?(Array) ? x.map(&:to_s) : x.to_s
  end

  def make_ruby_uri(x)
    input = x.is_a?(HyperionUri) ? x.to_s : x

    # URI is an oddball. It's a module but also a method on Kernel.
    # Since this class is a SimpleDelegator and SimpleDelegator is
    # a BasicObject, we need to pick the method off of Kernel.
    # We don't want to include Kernel because that would mess up delegation.
    Kernel.instance_method(:URI).bind(self).call(input)
  end
end
