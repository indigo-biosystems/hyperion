require 'uri'
require 'delegate'
require 'active_support/core_ext/hash/keys'
require 'rack/utils'

class HyperionUri < SimpleDelegator
  attr_accessor :query_hash

  def initialize(*args)
    init = proc do |uri, query_hash|
      @uri = uri
      __setobj__(@uri)
      query_from_uri = parse_query(uri.query || '')
      additional_query_params = validate_query(query_hash).stringify_keys
      @query_hash = query_from_uri.merge(additional_query_params)
    end

    if args.size <= 2
      uri, query_hash = *args
      uri = uri.is_a?(HyperionUri) ? uri.to_s : uri
      query_hash ||= {}
      init.call(make_ruby_uri(uri), query_hash)
    else
      scheme = args.first
      klass = scheme == 'https' ? URI::HTTPS : URI::HTTP
      init.call(klass.new(*args), nil)
    end
  end

  def query
    query_string(@query_hash)
  end

  def query=(query)
    @query_hash = parse_query(query)
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
    query.is_a?(Hash) or raise 'query must be a hash'
    query.values.all?(&method(:simple_value?)) or raise 'query values must be simple'
    query
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
    Rack::Utils.parse_nested_query(query)
  end

  def query_string(query_hash)
    return nil if query_hash == {}
    sorted = Hash[query_hash.map{|(k, v)| [k.to_s, stringify(v)]}.sort_by{|(k, v)| k}]
    Rack::Utils.build_nested_query(sorted)
  end

  def stringify(x)
    x.is_a?(Array) ? x.map(&:to_s) : x.to_s
  end

  def make_ruby_uri(x)
    # URI is an oddball. It's a module but also a method on Kernel.
    # Since this class is a SimpleDelegator and SimpleDelegator is
    # a BasicObject, we need to pick the method off of Kernel.
    # We don't want to include Kernel because that would mess up delegation.
    Kernel.instance_method(:URI).bind(self).call(x)
  end
end
