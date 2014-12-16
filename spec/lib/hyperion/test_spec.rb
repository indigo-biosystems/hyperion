require 'spec_helper'
require 'hyperion-test/test'


describe Hyperion do
  include Hyperion::Formats

  shared_examples 'a web server' do
    let(:user_response_params) { ResponseParams.new('user', 1, :json) }
    it 'implements specific routes' do
      create_fake_server do |svr|
        svr.allow(:get, '/users/0') do
          success_response({'name' => 'freddy'})
        end
        svr.allow(:post, '/say_hello') do |req|
          success_response({'greeting' => "hello, #{req.body['name']}"})
        end
      end

      result = Hyperion.get('http://yoursite.com:3000/users/0', user_response_params)
      expect(result.code).to eql 200
      expect(result.status).to eql Hyperion::Result::Status::SUCCESS
      expect(result.body).to eql({'name' => 'freddy'})

      response_params = ResponseParams.new('greeting', 1, :json)
      result = Hyperion.post('http://yoursite.com:3000/say_hello', response_params, write({'name' => 'freddy'}, :json), :json)
      expect(result.code).to eql 200
      expect(result.status).to eql Hyperion::Result::Status::SUCCESS
      expect(result.body).to eql({'greeting' => 'hello, freddy'})
    end

    it 'considers the HTTP method to be part of the route' do
      create_fake_server do |svr|
        svr.allow(:get, '/users/0') do
          success_response({'name' => 'freddy'})
        end
        svr.allow(:post, '/users/0') do |req|
          success_response({'updated' => {'name' => req.body['name']}})
        end
      end
      result = Hyperion.get('http://yoursite.com:3000/users/0', user_response_params)
      expect(result.body).to eql({'name' => 'freddy'})

      result = Hyperion.post('http://yoursite.com:3000/users/0', user_response_params, write({'name' => 'annie'}, :json), :json)
      expect(result.body).to eql({'updated' => {'name' => 'annie'}})
    end

    it 'considers the path to be part of the route' do
      create_fake_server do |svr|
        svr.allow(:get, '/users/0') do
          success_response({'name' => 'freddy'})
        end
        svr.allow(:get, '/users/1') do
          success_response({'name' => 'annie'})
        end
      end

      result = Hyperion.get('http://yoursite.com:3000/users/0', user_response_params)
      expect(result.body).to eql({'name' => 'freddy'})

      result = Hyperion.get('http://yoursite.com:3000/users/1', user_response_params)
      expect(result.body).to eql({'name' => 'annie'})
    end

    it 'considers the headers to be part of the route' do
      create_fake_server do |svr|
        svr.allow(:get, '/users/0', {'Accept' => 'application/vnd.indigobio-ascent.user-v1+json'}) do
          success_response({'name' => 'freddy'})
        end
        svr.allow(:get, '/users/0', {'Accept' => 'application/vnd.indigobio-ascent.full_user-v1+json'}) do
          success_response({'first_name' => 'freddy', 'last_name' => 'kruger', 'address' => 'Elm Street'})
        end
      end
      result = Hyperion.get('http://yoursite.com:3000/users/0', user_response_params)
      expect(result.body).to eql({'name' => 'freddy'})

      full_user_response_params = ResponseParams.new('full_user', 1, :json)
      result = Hyperion.get('http://yoursite.com:3000/users/0', full_user_response_params)
      expect(result.body).to eql({'first_name' => 'freddy', 'last_name' => 'kruger', 'address' => 'Elm Street'})
    end

    it 'considers the domain to be part of the route'
    # TODO: i.e., 'hello.com' vs 'goodbye.com'; since we are wiping out the domain as part of using Mimic,
    # TODO: we need to find a way to add the domain [use ports] (and maybe protocol as below) to mimic.
    it 'considers the protocol to be part of the route' #TODO: should this actually be true?

    def create_fake_server(opts={}, &routes)
      base_uri = "#{opts[:proto] || 'http'}://#{opts[:domain] || 'yoursite.com'}:#{opts[:port] || 3000}"
      Hyperion.send(type, base_uri, &routes)
    end

    def success_response(body)
      [200, {'Content-Type' => 'application/json'}, write(body, :json)]
    end
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

