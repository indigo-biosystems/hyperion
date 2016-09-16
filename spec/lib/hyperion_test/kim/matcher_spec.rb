require 'rspec'
require 'hyperion_test/kim'
require 'hyperion_test/kim/matcher'
require 'hyperion_test/kim/matchers'

describe Hyperion::Kim::Matcher do
  Matcher = Hyperion::Kim::Matcher
  Request = Hyperion::Kim::Request
  include Hyperion::Kim::Matchers

  describe '::new' do
    it 'creates a matcher' do
      m = Matcher.new(proc { |x| x >= 0 })
      expect(m.call(1)).to be_truthy
      expect(m.call(-1)).to be_falsey
    end
    it 'accepts a block' do
      m = Matcher.new { |x| x >= 0 }
      expect(m.call(1)).to be_truthy
      expect(m.call(-1)).to be_falsey
    end
    it 'can return a request' do
      m = res('/greet/:name')
      r = m.call(req('/greet/kim'))
      expect(r.params.name).to eql 'kim'
      expect(m.call(req('/text/kim'))).to be_falsey
    end
    it 'treats errors as falsey' do
      m = Matcher.new { raise 'oops' }
      expect(m.call(:anything)).to be_falsey
    end
  end
  describe '#call' do
    it 'invokes the predicate' do
      m = Matcher.new { |x| x >= 0 }
      expect(m.call(1)).to be_truthy
      expect(m.call(-1)).to be_falsey
    end
  end
  describe '#and' do
    it 'combines predicates with boolean AND' do
      positive = Matcher.new { |x| x > 0 }
      even = Matcher.new(&:even?)
      m = positive.and(even)
      expect(m.call(2)).to be_truthy
      expect(m.call(-2)).to be_falsey
      expect(m.call(1)).to be_falsey
      expect(m.call(-1)).to be_falsey
    end
    it 'merges result hash' do
      matcher = res('/greet/:name').and(res('/:action/kim'))
      verify_path_match matcher, '/greet/kim', yields_params: {name: 'kim', action: 'greet'}
      verify_path_does_not_match matcher, '/greet/bob'
      verify_path_does_not_match matcher, '/text/kim'
      verify_path_does_not_match matcher, '/text/bob'
    end
  end
  describe '#or' do
    it 'combines predicates with boolean OR' do
      positive = Matcher.new { |x| x > 0 }
      even = Matcher.new(&:even?)
      m = positive.or(even)
      expect(m.call(2)).to be_truthy
      expect(m.call(-2)).to be_truthy
      expect(m.call(1)).to be_truthy
      expect(m.call(-1)).to be_falsey
    end
    it 'returns result hash of first matching predicate' do
      matcher = res('/greet/:name').or(res('/:action/kim'))
      verify_path_match matcher, '/greet/kim', yields_params: {name: 'kim'}
      verify_path_match matcher, '/text/kim', yields_params: {action: 'text'}
      verify_path_does_not_match matcher, '/text/bob'
    end
  end
  describe '#not' do
    it 'returns a negated predicate' do
      even = Matcher.new(&:even?)
      odd = even.not
      expect(odd.call(1)).to be_truthy
      expect(odd.call(2)).to be_falsey
    end
  end
  describe '::and' do
    it 'combines predicates with boolean AND' do
      positive = Matcher.new { |x| x > 0 }
      even = Matcher.new(&:even?)
      mult10 = Matcher.new { |x| x % 10 == 0 }
      m = Matcher.and(positive, even, mult10)
      expect(m.call(10)).to be_truthy
      expect(m.call(-10)).to be_falsey
    end
  end
  context 'when the request is augmented with params' do
    let(:matcher) do
      match_people = res('/people/:name')
      name_starts_with_k = Matcher.new { |r| r.params.name.start_with?('k') }
      match_people.and(name_starts_with_k)
    end
    it 'the params are updated as the predicate executes' do
      verify_path_match matcher, '/people/kim'
      verify_path_does_not_match matcher, '/people/kim'
      verify_path_does_not_match matcher, '/people/bob'
      verify_path_does_not_match matcher, '/idiots/kanye'
    end
    it 'the original request is unchanged' do
      original_request = req('/people/kim')
      augmented_request = matcher.call(original_request)
      expect(augmented_request.params.name).to eql 'kim'
      expect(original_request.params.name).to be nil
    end
  end

  def req(path)
    Request.new('GET', path, OpenStruct.new, {}, nil)
  end

  def verify_path_match(matcher, path, yields_params: nil)
    result = matcher.call(req(path))
    expect(result).to be_truthy
    expect(result.params.to_h).to eql(yields_params) if yields_params
  end

  def verify_path_does_not_match(matcher, path)
    expect(matcher.call(res(path))).to be_falsey
  end
end
