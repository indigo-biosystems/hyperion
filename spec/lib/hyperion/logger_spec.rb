require 'rspec'
require 'hyperion'
require 'stringio'

describe Hyperion::Logger do
  include Hyperion::Logger

  it 'should log to $stdout by default' do
    output = StringIO.new
    with_stdout(output) do
      logger.debug 'xyzzy'
      logger.debug 'qwerty'
    end
    output_str = output.string
    expect(output_str).to include 'xyzzy'
    expect(output_str).to include 'qwerty'
  end

  it 'should log to Rails.logger if present' do
    rails, logger = double, double
    allow(rails).to receive(:logger).and_return(logger)
    expect(logger).to receive(:debug).with('xyzzy')

    with_rails(rails) do
      logger.debug 'xyzzy'
    end
  end

  def with_stdout(tmp_stdout)
    old = $stdout
    $stdout = tmp_stdout
    begin
      yield
    ensure
      $stdout = old
    end
  end

  def with_rails(rails)
    Kernel.const_set(:Rails, rails)
    begin
      yield
    ensure
      Kernel.send(:remove_const, :Rails)
    end
  end
end
