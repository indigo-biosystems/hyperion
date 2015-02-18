require 'uri'
require 'delegate'
require 'active_support/core_ext/hash/keys'

class HyperionUri < SimpleDelegator
  attr_accessor :query_hash

  def initialize(*args)
    init = proc do |uri, query_hash|
      @uri = uri
      __setobj__(@uri)
      @query_hash = parse_query(uri.query || '').merge(query_hash.stringify_keys)
    end

    if args.size <= 2
      uri, query_hash = *args
      query_hash ||= {}
      uri = uri.is_a?(HyperionUri) ? uri.to_s : uri
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

  def parse_query(query)
    Hash[query.split('&').map(&method(:parse_attr))]
  end

  def parse_attr(field_and_value)
    f, v = field_and_value.split('=')
    [f, URI.decode_www_form_component(v)]
  end

  def query_string(query_hash)
    return nil if query_hash == {}
    query_hash.stringify_keys.sort_by{|(k, v)| k}.map{|(k, v)| "#{k.to_s}=#{URI.encode_www_form_component(v)}"}.join('&')
  end

  def make_ruby_uri(x)
    # URI is an oddball. It's a module but also a method on Kernel.
    # Since this class is a SimpleDelegator and SimpleDelegator is
    # a BasicObject, we need to pick the method off of Kernel.
    # We don't want to include Kernel because that would mess up delegation.
    Kernel.instance_method(:URI).bind(self).call(x)
  end
end
