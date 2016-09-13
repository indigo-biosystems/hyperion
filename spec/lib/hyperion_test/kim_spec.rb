require 'rspec'
require 'hyperion_test/kim'
require 'typhoeus'

describe Hyperion::Kim do
  before(:all) do
    @port = 9001
    @kim = Hyperion::Kim.new(port: @port)
    @kim.start
  end
  before(:each) { @kim.clear_handlers }
  after(:all) { @kim.stop }
  attr_accessor :kim

  let!(:always) { proc { true } }

  context 'normal operation' do
    it 'routes to a block' do
      kim.add_handler(always) { 'Hello, World!' }
      expect(get_body('/')).to eql 'Hello, World!'
    end
    it 'routes to the most recently added handler with a true predicate' do
      kim.add_handler(proc{false}) { 'a' }
      kim.add_handler(proc{true}) { 'b' }
      kim.add_handler(proc{true}) { 'c' }
      kim.add_handler(proc{false}) { 'd' }
      expect(get_body('/')).to eql 'c'
    end
    it 'allows multiple servers running in parallel' do
      kim2 = Hyperion::Kim.new(port: 9002)
      begin
        kim2.start
        kim.add_handler(always) { '1' }
        kim2.add_handler(always) { '2' }
        expect(Typhoeus.get('http://localhost:9001').body).to eql '1'
        expect(Typhoeus.get('http://localhost:9002').body).to eql '2'
        kim2.stop
        expect(Typhoeus.get('http://localhost:9001').body).to eql '1'
        expect(Typhoeus.get('http://localhost:9002').success?).to be false
      ensure
        kim2.stop
      end
    end
  end

  describe '#add_handler' do
    it 'returns a remover proc' do
      remover = kim.add_handler(always) { 'foo' }
      expect(get_body('/')).to eql 'foo'
      remover.call
      expect(get_code('/')).to eql 400
    end
  end

  describe '#clear_handlers' do
    it 'clears all handlers' do
      kim.add_handler(always) { 'foo' }
      expect(get_body('/')).to eql 'foo'
      kim.clear_handlers
      expect(get_code('/')).to eql 400
    end
  end

  describe 'a handler' do
    it 'receives the HTTP verb' do
      verb = nil
      method = nil
      kim.add_handler(always) do |r|
        verb = r.verb
        method = r.method
      end
      post('/')
      expect(verb).to eql 'POST'
      expect(method).to eql 'POST'
    end
    it 'receives the resource path' do
      path = nil
      kim.add_handler(always) { |r| path = r.path; '' }
      get('/foo/bar')
      expect(path).to eql '/foo/bar'
    end
    it 'receives the params' do
      params = nil
      kim.add_handler(proc{{d: '4', e: '5'}}) { |r| params = r.params; '' }
      get('/foo/bar?a=1&b=2&c=3')
      expect(params.a).to eql '1'
      expect(params[:b]).to eql '2'
      expect(params['c']).to eql '3'
      expect(params.d).to eql '4'
      expect(params.e).to eql '5'
    end
    it 'receives the request headers' do
      headers = nil
      kim.add_handler(always) { |r| headers = r.headers; '' }
      get('/', headers: {'Accept' => 'application/json', 'Content-Type' => 'text/html'})
      expect(headers['Accept']).to eql 'application/json'
      expect(headers['Content-Type']).to eql 'text/html'
    end
    it 'receives the request body' do
      body = nil
      kim.add_handler(always) { |r| body = r.body; '' }
      post('/', body: 'please do something')
      expect(body).to eql 'please do something'
    end
    it 'can return a string' do
      kim.add_handler(always) { 'hello' }
      r = get('/')
      expect(r.code).to eql 200
      expect(r.body).to eql 'hello'
    end
    it 'can return a rack response' do
      kim.add_handler(always) { ['400', {'Content-Type' => 'application/greeting'}, ['oops']] }
      r = get('/')
      expect(r.body).to eql 'oops'
      expect(r.code).to eql 400
      expect(r.headers['Content-Type']).to eql 'application/greeting'
    end
    it 'rack response requirements are somewhat loosened' do
      kim.add_handler(always) { [400, nil, 'oops'] }
      r = get('/')
      expect(r.body).to eql 'oops'
      expect(r.code).to eql 400
    end
  end

  def get_body(path)
    response = get(path)
    expect(response.success?).to be true
    response.body
  end

  def base_uri
    "http://localhost:#{@port}"
  end

  def get_code(path)
    get(path).code
  end

  def get(path, headers: {})
    Typhoeus.get(File.join(base_uri, path), headers: headers)
  end

  def post(path, headers: {}, body: nil)
    Typhoeus.post(File.join(base_uri, path), headers: headers, body: body)
  end
end
