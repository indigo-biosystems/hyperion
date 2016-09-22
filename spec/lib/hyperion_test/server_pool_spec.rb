require 'rspec'
require 'hyperion_test'

describe Hyperion::ServerPool do

  let(:pool) { Hyperion::ServerPool.new }
  before(:each) do
    allow(Hyperion::FakeServer).to receive(:new) do
      server = double
      allow(server).to receive(:teardown)
      server
    end
  end

  describe '#check_out' do
    it 'creates a new server if there are none free' do
      new_server = double
      expect(Hyperion::FakeServer).to receive(:new).and_return(new_server)
      expect(pool.check_out).to eql new_server
    end
    it 'returns a free server' do
      server = pool.check_out
      pool.check_in(server)
      expect(pool.check_out).to eql server
    end
  end

  describe '#check_in' do
    it 'returns a server to the pool' do
      server = pool.check_out
      pool.check_in(server)
      expect(pool.check_out).to eql server
    end
  end

  describe '#clear' do
    it 'tears down both checked out and checked in servers' do
      a = pool.check_out
      b = pool.check_out
      pool.check_in(b)
      expect(a).to receive(:teardown)
      expect(b).to receive(:teardown)
      pool.clear
    end
  end
end
