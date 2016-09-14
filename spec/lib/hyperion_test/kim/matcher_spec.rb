require 'rspec'
require 'hyperion_test/kim/matcher'

describe Hyperion::Kim::Matcher do
  Matcher = Hyperion::Kim::Matcher
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
    it 'can return a hash' do
      m = Matcher.new { |s| s =~ /Hello, (\w+)!/ ? {name: $1} : nil }
      matched = m.call('Hello, Kim!')
      expect(matched[:name]).to eql 'Kim'
      expect(m.call('Goodbye, Kim!')).to be_falsey
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
    it 'merges result hashes' do
      m = match_hello.and(match_kim)
      expect(m.call('Hello, Kim!')).to eql({name: 'Kim', salutation: 'Hello'})
      expect(m.call('Hello, Bob!')).to be_falsey
      expect(m.call('Goodbye, Kim!')).to be_falsey
      expect(m.call('Goodbye, Bob!')).to be_falsey
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
    it 'merges result hashes' do
      m = match_hello.or(match_kim)
      expect(m.call('Hello, Kim!')).to eql({name: 'Kim', salutation: 'Hello'})
      expect(m.call('Hello, Bob!')).to eql({name: 'Bob'})
      expect(m.call('Goodbye, Kim!')).to eql({salutation: 'Goodbye'})
      expect(m.call('Goodbye, Bob!')).to be_falsey
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
  context 'when the object has params' do
    it 'updates the params as the predicate executes' do
      make_req = proc { |path| OpenStruct.new(path: path, params: {}) }
      match_people = Matcher.new { |r| r.path =~ /\/people\/(\w+)/ ? {name: $1} : nil }
      name_starts_with_k = Matcher.new { |r| r.params.name.start_with?('k') }
      m = match_people.and(name_starts_with_k)
      expect(m.call(make_req.call('/people/kim'))).to be_truthy
      expect(m.call(make_req.call('/people/bob'))).to be_falsey
      expect(m.call(make_req.call('/idiots/kanye'))).to be_falsey
    end
  end
  def match_hello
    Matcher.new { |s| s =~ /Hello, (\w+)!/ ? {name: $1} : nil }
  end
  def match_kim
    Matcher.new { |s| s =~ /(\w+), Kim!/ ? {salutation: $1} : nil }
  end
end
