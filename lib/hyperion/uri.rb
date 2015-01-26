# monkeypatch ruby's URI
module URI

  # @return [String] the URI base e.g., "h\ttp://somehost:80"
  def base
    "#{scheme}://#{host}:#{port}"
  end

  # @return [URI] a copy of the URI with a new scheme, host, and port
  def change_base(uri_with_new_base)
    uri = self.dup
    uri.scheme = uri_with_new_base.scheme
    uri.host = uri_with_new_base.host
    uri.port = uri_with_new_base.port
    uri
  end
end
