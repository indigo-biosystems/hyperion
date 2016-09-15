require 'rspec'
require 'hyperion_test/kim'
require 'hyperion_test/kim/matchers'

describe Hyperion::Kim::Matchers do
  include Hyperion::Kim::Matchers
  describe '#res' do
    it 'matches resource paths' do
      m = res('/people/:name/birthplace/:city')
      r = m.call(req(path: '/people/kim/birthplace/la'))
      expect(r.params.name).to eql 'kim'
      expect(r.params.city).to eql 'la'
      expect(m.call(req(path: '/people/kim/home/la'))).to be_falsey
    end
  end
  describe '#verb' do
    it 'matches the HTTP verb' do
      expect(verb('GET').call(req(verb: 'GET'))).to be_truthy
      expect(verb('PUT').call(req(verb: 'put'))).to be_truthy
      expect(verb('GET').call(req(verb: 'PUT'))).to be_falsey
    end
  end
  describe '#req_headers' do
    it 'matches headers' do
      m = req_headers('Allow' => 'application/json')
      expect(m.call(req(headers: {'Allow' => 'application/json'}))).to be_truthy
      expect(m.call(req(headers: {'Allow' => 'text/html'}))).to be_falsey
      expect(m.call(req(headers: {}))).to be_falsey
    end
    it 'only checks for presence if value is nil' do
      m = req_headers('Allow' => nil)
      expect(m.call(req(headers: {'Allow' => 'application/json'}))).to be_truthy
      expect(m.call(req(headers: {'Allow' => 'text/html'}))).to be_truthy
      expect(m.call(req(headers: {}))).to be_falsey
    end
  end
  describe '#req_params' do
    it 'matches params' do
      m = req_params(a: 1, 'b' => 2)
      expect(m.call(req(params: params(a: 1, b: 2)))).to be_truthy
    end
    it 'only checks for presence if value is nil' do
      m = req_params(c: nil)
      expect(m.call(req(params: params(c: 1)))).to be_truthy
      expect(m.call(req(params: params(c: 2)))).to be_truthy
      expect(m.call(req(params: params(z: 2)))).to be_falsey
    end
  end

  def req(attrs)
    Hyperion::Kim::Request.new(*attrs.values_at(*Hyperion::Kim::Request.members))
  end

  def params(*args)
    OpenStruct.new(*args)
  end
end
