require 'rspec'
require 'hyperion'
require 'stringio'

describe Hyperion::Logger do
  include Hyperion::Logger

  it 'logs to $stdout by default' do
    output = StringIO.new
    with_stdout(output) do
      logger.debug 'xyzzy'
      logger.debug 'qwerty'
    end
    output_str = output.string
    expect(output_str).to include 'xyzzy'
    expect(output_str).to include 'qwerty'
  end

  it 'logs to Rails.logger if present' do
    rails, logger = double, double
    allow(rails).to receive(:logger).and_return(logger)
    expect(logger).to receive(:debug).with('xyzzy')

    with_rails(rails) do
      logger.debug 'xyzzy'
    end
  end

  it 'respects the log level' do
    output = StringIO.new
    with_stdout(output) do
      Logatron.level = Logatron::ERROR
      logger.debug 'xyzzy'
      logger.error 'qwerty'
      Logatron.level = Logatron::DEBUG
    end
    output_str = output.string
    expect(output_str).to include 'qwert'
    expect(output_str).to_not include 'xyzzy'
  end

  def with_stdout(io)
    set_log_io(io)
    begin
      yield
    ensure
      set_log_io($stdout)
    end
  end

  def set_log_io(io)
    Logatron.configure do |c|
      c.logger = Logger.new(io)
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
