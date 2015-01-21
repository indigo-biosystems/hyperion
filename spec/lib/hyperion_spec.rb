require 'rspec'
require 'hyperion'
require 'stringio'

describe Hyperion do

  include Hyperion::Formats

  shared_examples 'a generic hyperion request' do
    it 'performs the request using Typhoeus' do
      uri = 'http://example.com:12345/hi/there'
      response_body = {'a' => 1}
      expect(Hyperion::Typho).to receive(:request).with(uri, expected_opts) { mock_json_response(200, response_body) }
      result = Hyperion.new(uri, ResponseParams.new('ttt', 999, :json)).send(method, *args)
      expect(result.status).to eql Hyperion::Result::Status::SUCCESS
      expect(result.code).to eql 200
      expect(result.body).to eql response_body
    end
  end

  def mock_json_response(code, hash)
    r = double
    allow(r).to receive(:success?) { 200 <= code && code < 300 }
    allow(r).to receive(:code) { code }
    allow(r).to receive(:body) { write(hash, :json) }
    r
  end

  shared_examples 'a hyperion request without a body' do
    let!(:expected_opts){{
        method: method,
        headers: {
            'Accept' => 'application/vnd.indigobio-ascent.ttt-v999+json'
        },
        body: nil
    }}
    let!(:args){[]}
    it_behaves_like 'a generic hyperion request'
  end

  shared_examples 'a hyperion request with a body' do
    let!(:expected_opts){{
        method: method,
        headers: {
            'Accept' => 'application/vnd.indigobio-ascent.ttt-v999+json',
            'Content-Type' => 'application/json'
        },
        body: body
    }}
    it_behaves_like 'a generic hyperion request'
  end

  describe '#get' do
    let!(:method){:get}
    it_behaves_like 'a hyperion request without a body'
  end

  describe '#post' do
    let!(:method){:post}
    let!(:body){'{"info":888}'}
    let!(:args){['{"info":888}', :json]}
    it_behaves_like 'a hyperion request with a body'
  end

  describe '#put' do
    let!(:method){:put}
    let!(:body){'{"info":888}'}
    let!(:args){['{"info":888}', :json]}
    it_behaves_like 'a hyperion request with a body'
  end

  describe '#delete' do
    let!(:method){:delete}
    it_behaves_like 'a hyperion request without a body'
  end

  describe '::request' do
    it 'delegates to #request' do
      method = :xyz
      path, uri, response_params = 3.times.map{double}
      route = RestRoute.new(method, path, uri, response_params)
      hyp = double
      arg1, arg2 = double, double
      expect(Hyperion).to receive(:new).with(uri, response_params).and_return(hyp)
      expect(hyp).to receive(method).with(arg1, arg2)

      Hyperion.request(route, arg1, arg2)
    end
  end
end
