require 'spec_helper'
require 'hyperion-test/test'


describe Hyperion do
  include Hyperion::Formats

  # Hyperion.fake(AppConfig.assaymatic_base_uri) do |svr|
  #   svr.expect(:post, "/sites/#{AppConfig.site}/production_assay_configurations/promote", expected_headers) do |req|
  #     expect(req.body['name']).to eql config.name
  #     [200, {'Content-Type' => 'application/json'}, config.attributes.as_json.to_json]
  #   end
  # end

  shared_examples 'a web server' do
    it 'implements specific routes' do
      Hyperion.send(type, 'http://yoursite.com:3000') do |svr|
        svr.allow(:get, '/users/0') do
          [200, {'Content-Type' => 'application/json'}, write({'name' => 'freddy'}, :json)]
        end
        svr.allow(:post, '/say_hello') do |req|
          [200, {'Content-Type' => 'application/json'}, write({'greeting' => "hello, #{req.body['name']}"}, :json)]
        end
      end

      response_params = Hyperion::ResponseParams.new('user', 1, :json)
      result = Hyperion.get('http://yoursite.com:3000/users/0', response_params)
      expect(result.code).to eql 200
      expect(result.status).to eql Hyperion::Result::Status::SUCCESS
      expect(result.body).to eql({'name' => 'freddy'})

      response_params = Hyperion::ResponseParams.new('greeting', 1, :json)
      result = Hyperion.post('http://yoursite.com:3000/say_hello', response_params, write({'name' => 'freddy'}, :json), :json)
      expect(result.code).to eql 200
      expect(result.status).to eql Hyperion::Result::Status::SUCCESS
      expect(result.body).to eql({'greeting' => 'hello, freddy'})
    end

    it 'considers the HTTP method to be part of the route'
    it 'considers the path to be part of the route'
    it 'considers the headers to be part of the route'
  end

  # describe '::stub' do
  #   it_behaves_like 'a web server' do
  #     let(:type) { :stub }
  #   end
  # end

  describe '::fake' do
    it_behaves_like 'a web server' do
      let(:type) { :fake }
    end
  end
end

