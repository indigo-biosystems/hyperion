require 'superion'
require 'hyperion_test'

# class PointEntity < Entity
#   custom_accessor :x
#   custom_accessor :y
# end

describe Superion do
  include Superion

  # attr_reader :superion_handlers
  # before(:each) { @superion_handlers = {} }

  def arrange(method, response)
    @route = RestRoute.new(method, 'http://indigo.com/things',
                           ResponseDescriptor.new('thing', 1, :json),
                           PayloadDescriptor.new(:json))

    fake_route(@route) do |request|
      @request = request
      response
    end
  end

  def assert_result(expected_result)
    expect(@result).to eql expected_result
  end

  it 'makes requests' do
    arrange(:get, {'a' => 'b'})
    @result = request(@route)
    assert_result({'a' => 'b'})
  end

  it 'makes requests with payload bodies' do
    arrange(:put, {'a' => 'b'})
    @result = request(@route, body: {'the' => 'body'})
    assert_result({'a' => 'b'})
    expect(@request.body).to eql({'the' => 'body'})
  end

  # uses Entity. fix.
  # it 'renders the response as an entity' do
  #   arrange(:get, {'x' => 1, 'y' => 2})
  #   @result = request(@route, render: as(PointEntity))
  #   assert_result(PointEntity.new(x: 1, y: 2))
  # end
  #
  # uses Entity. fix.
  # it 'renders the response as multiple entities' do
  #   arrange(:get, [{'x' => 1, 'y' => 2}, {'x' => 3, 'y' => 4}])
  #   @result = request(@route, render: as_many(PointEntity))
  #   assert_result([PointEntity.new(x: 1, y: 2), PointEntity.new(x: 3, y: 4)])
  # end

  # broken, fix later
  # it 'uses handlers returned by a `superion_handlers` method, if present' do
  #   arrange(:get, [444, {}, nil])
  #   @superion_handlers = {444 => 'got 444'}
  #   @result = request(@route)
  #   expect(@result).to eql 'got 444'
  # end

  # broken, fix later
  # it 'superion_handlers overrides the default handlers' do
  #   arrange(:get, [444, {}, nil])
  #   @superion_handlers = {400..499 => 'got 400-level'}
  #   @result = request(@route)
  #   expect(@result).to eql 'got 400-level'
  # end

  # broken, fix later
  # it 'earlier handlers take precedence over later ones' do
  #   arrange(:get, [333, {}, nil])
  #   @superion_handlers = {
  #       proc {|x|
  #         x.code.odd?
  #       } => 'odd',
  #       333 => 'got 333' }
  #
  #   @result = request(@route)
  #   expect(@result).to eql 'odd'
  # end

  # uses Entity. fix.
  # context 'when given a block' do
  #   before :each do
  #     arrange(:get, {'x' => 1, 'y' => 2})
  #     @result = request(@route, render: as(PointEntity)) do |point|
  #       @point = point
  #       :block_result
  #     end
  #   end
  #   it 'passes the rendered response to the block' do
  #     expect(@point).to be_a PointEntity
  #   end
  #   it "returns the block's return value" do
  #     expect(@result).to eql :block_result
  #   end
  # end

  it 'rejects invalid arguments' do
    arrange(:get, {'a' => 'b'})
    expect{request(:foo)}.to raise_error 'You passed me :foo, which is not a RestRoute'
    expect{request(@route, :foo)}.to raise_error 'You passed me :foo, which is not an options hash'
  end

  context 'by default' do
    context 'on a 400-level response' do

      def example(opts)
        arrange(:get, [(400..499).to_a.sample, {}, opts[:response]])
        expect{request(@route)}.to raise_error opts[:error]
      end

      context 'when the response is a properly-formed error message' do
        it 'raises an error with the response message' do
          example response: '{"message":"oops"}',
                  error: 'oops'
        end
      end
      context 'when the response is not a properly-formed error message' do
        it 'raises an error containing the route and the dumped response' do
          example response: '{"huh":"wut"}',
                  error: 'The request failed: GET http://indigo.com/things: {"huh"=>"wut"}'
        end
      end
      context 'when there is no response' do
        it 'raises an generic error message containing the route' do
          example response: nil,
                  error: 'The request failed: GET http://indigo.com/things'
        end
      end
    end
  end
end
