require 'spec_helper'
require 'hyperion-test/test'


describe Hyperion do
  include Hyperion::Formats

  let(:user_response_params) { ResponseDescriptor.new('user', 1, :json) }

  context 'given some routes' do
    let!(:get_user_route){RestRoute.new(:get, 'http://somesite.org/users/0', user_response_params)}
    let!(:post_greeting_route){RestRoute.new(:post, 'http://somesite.org/say_hello',
                                             ResponseDescriptor.new('greeting', 1, :json),
                                             PayloadDescriptor.new(:json))}
    before :each do
      Hyperion.fake('http://somesite.org') do |svr|
        svr.allow(get_user_route) do
          {'name' => 'freddy'}
        end
        svr.allow(post_greeting_route) do |req|
          {'greeting' => "hello, #{req.body['name']}"}
        end
      end
    end
    it 'implements specific routes' do
      result = Hyperion.request(get_user_route)
      expect_success(result, {'name' => 'freddy'})

      result = Hyperion.request(post_greeting_route, write({'name' => 'freddy'}, :json))
      expect_success(result, {'greeting' => 'hello, freddy'})
    end
    it 'returns 404 if a requested route is not stubbed' do
      bad_path = RestRoute.new(:get, 'http://somesite.org/abc', user_response_params)
      bad_headers = RestRoute.new(:get, 'http://somesite.org/users/0', ResponseDescriptor.new('abc', 1, :json))

      result = Hyperion.request(bad_path)
      expect(result.code).to eql 404

      result = Hyperion.request(bad_headers)
      expect(result.code).to eql 404
    end

    context 'when a rack result is provided for the response' do

      it 'allows rack results to be returned' do
        arrange([400, {}, nil])
        act
        expect(@result.code).to eql 400
        expect(@result.body).to be_nil
      end

      it 'serializes the body as json if it is not a string' do
        arrange([400, {}, {'message' => 'oops'}])
        act
        expect(@result.body).to eql({'message' => 'oops'})
      end

      def arrange(response)
        Hyperion.fake(get_user_route.uri.base) do |svr|
          svr.allow(get_user_route) { response }
        end
      end

      def act
        @result = Hyperion.request(get_user_route)
      end
    end
  end

  it 'logs requests for unstubbed routes' do
    route1 = RestRoute.new(:get, 'http://site.org/stuff', user_response_params)
    route2 = RestRoute.new(:get, 'http://site.org/things', user_response_params)
    Hyperion.fake(route1.uri.base) do |svr|
      svr.allow(route1) {{}}
    end
    Hyperion.request(route2)
  end

  it 'considers the HTTP method to be part of the route' do
    Hyperion.fake('http://somesite.org') do |svr|
      svr.allow(:get, '/users/0') do
        success_response({'name' => 'freddy'})
      end
      svr.allow(:post, '/users/0') do |req|
        success_response({'updated' => {'name' => req.body['name']}})
      end
    end

    result = Hyperion.request(RestRoute.new(:get, 'http://somesite.org/users/0', user_response_params))
    expect(result.body).to eql({'name' => 'freddy'})

    result = Hyperion.request(RestRoute.new(:post, 'http://somesite.org/users/0',
                                            user_response_params, PayloadDescriptor.new(:json)),
                              write({'name' => 'annie'}, :json))
    expect(result.body).to eql({'updated' => {'name' => 'annie'}})
  end

  it 'considers the path to be part of the route' do
    Hyperion.fake('http://somesite.org') do |svr|
      svr.allow(:get, '/users/0') do
        success_response({'name' => 'freddy'})
      end
      svr.allow(:get, '/users/1') do
        success_response({'name' => 'annie'})
      end
    end

    result = Hyperion.request(RestRoute.new(:get, 'http://somesite.org/users/0', user_response_params))
    expect(result.body).to eql({'name' => 'freddy'})

    result = Hyperion.request(RestRoute.new(:get, 'http://somesite.org/users/1', user_response_params))
    expect(result.body).to eql({'name' => 'annie'})
  end

  it 'considers the headers to be part of the route' do
    Hyperion.fake('http://somesite.org') do |svr|
      svr.allow(:get, '/users/0', {'Accept' => 'application/vnd.indigobio-ascent.user-v1+json'}) do
        success_response({'name' => 'freddy'})
      end
      svr.allow(:get, '/users/0', {'Accept' => 'application/vnd.indigobio-ascent.full_user-v1+json'}) do
        success_response({'first_name' => 'freddy', 'last_name' => 'kruger', 'address' => 'Elm Street'})
      end
    end

    result = Hyperion.request(RestRoute.new(:get, 'http://somesite.org/users/0', user_response_params))
    expect(result.body).to eql({'name' => 'freddy'})

    full_user_response_params = ResponseDescriptor.new('full_user', 1, :json)
    result = Hyperion.request(RestRoute.new(:get, 'http://somesite.org/users/0', full_user_response_params))
    expect(result.body).to eql({'first_name' => 'freddy', 'last_name' => 'kruger', 'address' => 'Elm Street'})
  end

  it 'allows multiple fake servers to be created' do
    Hyperion.fake('http://google.com') do |svr|
      svr.allow(:get, '/welcome') { success_response({'text' => 'hello from google'}) }
    end

    Hyperion.fake('http://indigo.com:3000') do |svr|
      svr.allow(:get, '/welcome') { success_response({'text' => 'hello from indigo@3000'}) }
    end

    Hyperion.fake('http://indigo.com:4000') do |svr|
      svr.allow(:get, '/welcome') { success_response({'text' => 'hello from indigo@4000'}) }
    end

    result = Hyperion.request(RestRoute.new(:get, 'http://google.com/welcome', user_response_params))
    expect(result.body).to eql({'text' => 'hello from google'})

    result = Hyperion.request(RestRoute.new(:get, 'http://indigo.com:3000/welcome', user_response_params))
    expect(result.body).to eql({'text' => 'hello from indigo@3000'})

    result = Hyperion.request(RestRoute.new(:get, 'http://indigo.com:4000/welcome', user_response_params))
    expect(result.body).to eql({'text' => 'hello from indigo@4000'})
  end

  it 'defaults the base port to port 80' do
    Hyperion.fake('http://indigo.com') do |svr|
      svr.allow(:get, '/welcome') { success_response({'text' => 'old handler'}) }
    end

    # override the previous one
    Hyperion.fake('http://indigo.com:80') do |svr|
      svr.allow(:get, '/welcome') { success_response({'text' => 'new handler'}) }
    end

    result = Hyperion.request(RestRoute.new(:get, 'http://indigo.com/welcome', user_response_params))
    expect(result.body).to eql({'text' => 'new handler'})

    result = Hyperion.request(RestRoute.new(:get, 'http://indigo.com:80/welcome', user_response_params))
    expect(result.body).to eql({'text' => 'new handler'})
  end

  it 'allows routes to be augmented' do
    Hyperion.fake('http://google.com') do |svr|
      svr.allow(:get, '/old') { success_response({'text' => 'old'}) }
      svr.allow(:get, '/hello') { success_response({'text' => 'hello'}) }
      svr.allow(RestRoute.new(:get, '/users/0', user_response_params)) { success_response({'user' => 'old user'}) }
    end

    # smoke test that the server is up and running
    result = Hyperion.request(RestRoute.new(:get, 'http://google.com/hello', user_response_params))
    expect(result.body).to eql({'text' => 'hello'})

    # augment the routes
    Hyperion.fake('http://google.com') do |svr|
      svr.allow(:get, '/hello') { success_response({'text' => 'aloha'}) }
      svr.allow(:get, '/goodbye') { success_response({'text' => 'goodbye'}) }
      svr.allow(RestRoute.new(:get, '/users/0', user_response_params)) { success_response({'user' => 'new user'}) }
    end

    # untouched routes are left alone
    result = Hyperion.request(RestRoute.new(:get, 'http://google.com/old', user_response_params))
    expect(result.body).to eql({'text' => 'old'})

    # restating the route replaces it (last one wins)
    result = Hyperion.request(RestRoute.new(:get, 'http://google.com/hello', user_response_params))
    expect(result.body).to eql({'text' => 'aloha'})

    # new routes can be added
    result = Hyperion.request(RestRoute.new(:get, 'http://google.com/goodbye', user_response_params))
    expect(result.body).to eql({'text' => 'goodbye'})

    # restating a route routes that uses headers to differentiate replaces it (last one wins)
    result = Hyperion.request(RestRoute.new(:get, 'http://google.com/users/0', user_response_params))
    expect(result.body).to eql({'user' => 'new user'})
  end

  def success_response(body)
    [200, {'Content-Type' => 'application/json'}, write(body, :json)]
  end

  def expect_success(result, body)
    expect(result.status).to eql HyperionResult::Status::SUCCESS
    expect(result.code).to eql 200
    expect(result.body).to eql body
  end
end

