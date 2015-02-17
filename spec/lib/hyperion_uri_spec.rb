require 'rspec'
require 'hyperion'

describe HyperionUri do

  it 'behaves like a normal URI' do
    u = HyperionUri.new('http://yum.com:44/res?id=1&name=foo')
    expect(u.scheme).to eql 'http'
    expect(u.host).to eql 'yum.com'
    expect(u.port).to eql 44
    expect(u.path).to eql '/res'
    expect(u.query).to eql 'id=1&name=foo'
    expect(u.to_s).to eql 'http://yum.com:44/res?id=1&name=foo'
    expect(u.inspect).to include 'http://yum.com:44/res?id=1&name=foo'
  end

  it 'accepts additional query parameters as a hash' do
    u = HyperionUri.new('http://yum.com:44/res?id=1&name=foo', site: 'box')
    expect(u.query).to eql 'id=1&name=foo&site=box'
    expect(u.to_s).to eql 'http://yum.com:44/res?id=1&name=foo&site=box'
    expect(u.inspect).to match %r{#<HyperionUri:0x[0-9a-f]+ http://yum\.com:44/res\?id=1&name=foo&site=box>}
  end

  it 'hash parameters override parameters in the uri' do
    u = HyperionUri.new('http://yum.com:44/res?id=1&name=foo', name: 'bar')
    expect(u.query).to eql 'id=1&name=bar'
  end

  it 'escapes query param values' do
    u = HyperionUri.new('http://yum.com:44/res', name: 'foo bar', title: 'x&y')
    expect(u.query).to eql 'name=foo+bar&title=x%26y'
  end

  it 'allows the query hash to be modified after construction' do
    u = HyperionUri.new('http://yum.com:44/res')
    u.query_hash[:name] = 'foo bar'
    expect(u.query).to eql 'name=foo+bar'
  end

  it 'allows both string or symbol keys' do
    u = HyperionUri.new('http://yum.com:44/res')
    u.query_hash[:name] = 'foo bar'
    u.query_hash['id'] = '123'
    expect(u.query).to eql 'name=foo+bar&id=123'
  end

  it 'setting a query string replaces the query hash' do
    u = HyperionUri.new('http://yum.com:44/res', name: 'foo bar')
    u.query = 'a=1'
    expect(u.query).to eql 'a=1'
    expect(u.query_hash).to eql({'a' => '1'})
  end

  describe '#initialize' do
    it 'accepts strings' do
      u = HyperionUri.new('http://yum.com')
      expect(u.to_s).to eql 'http://yum.com'
    end
    it 'accepts HTTP URIs' do
      u = HyperionUri.new(URI('http://yum.com'))
      expect(u.to_s).to eql 'http://yum.com'
    end
    it 'accepts HTTPS URIs' do
      u = HyperionUri.new(URI('https://yum.com'))
      expect(u.to_s).to eql 'https://yum.com'
    end
    it 'accepts HyperionUris' do
      a = HyperionUri.new('http://yum.com', name: 'foo bar')
      u = HyperionUri.new(a)
      expect(u.to_s).to eql 'http://yum.com?name=foo+bar'
    end
  end

  describe '#base' do
    it 'returns the base uri' do
      u = HyperionUri.new('http://yum.com:44/res')
      expect(u.base).to eql 'http://yum.com:44'
    end
  end

  describe '#base=' do
    it 'sets the base uri' do
      u = HyperionUri.new('http://yum.com:44/res/123')
      u.base = 'https://hello.com:55'
      expect(u.to_s).to eql 'https://hello.com:55/res/123'
    end
  end
end
