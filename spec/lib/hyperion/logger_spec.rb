require 'rspec'
require 'hyperion'
require 'stringio'

describe Hyperion::Logger do
  include Hyperion::Logger

  it 'logs to $stdout by default' do
    output = capture_stdout do
      logger.debug 'xyzzy'
      logger.debug 'qwerty'
    end
    expect(output).to include 'xyzzy'
    expect(output).to include 'qwerty'
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
    output = capture_stdout do
      Logatron.level = Logatron::ERROR
      logger.debug 'xyzzy'
      logger.error 'qwerty'
      Logatron.level = Logatron::DEBUG
    end
    expect(output).to include 'qwert'
    expect(output).to_not include 'xyzzy'
  end

  context '::log_result' do
    let(:response_desc) { ResponseDescriptor.new('type', 1, :json) }
    let(:payload_desc) { PayloadDescriptor.new(:protobuf) }
    let(:route) { RestRoute.new(:get, 'http://test.com', response_desc, payload_desc) }

    context 'for a successful response' do
      let(:result) { HyperionResult.new(route, HyperionStatus::SUCCESS, 200, 'test') }
      it 'does not log anything' do
        output = capture_stdout do
          log_result(result)
        end
        expect(output).to be_empty
      end
    end

    context 'for an unsuccessful response' do
      context 'with no body' do
        let(:result) { HyperionResult.new(route, HyperionStatus::TIMED_OUT) }
        it 'does not log anything ' do
          output = capture_stdout do
            log_result(result)
          end
          expect(output).to be_empty
        end
      end

      context 'with a ClientErrorResponse body' do
        let(:message) { 'test' }
        let(:code) { ClientErrorCode::MISSING }
        let(:error) { ClientErrorDetail.new(code, 'resource', field: 'field', value: 1, reason: 'oops') }
        let(:content) { 'content' }
        let(:error_response) { ClientErrorResponse.new(message, [error], code, content) }
        let(:result) { HyperionResult.new(route, HyperionStatus::CLIENT_ERROR, 400, error_response) }
        it 'logs the key value pairs of the ClientErrorResponse' do
          output = capture_stdout do
            log_result(result)
          end
          pairs = error_response.as_json
          errors = pairs.delete('errors').first
          ensure_key_value_pairs_logged(pairs, output)
          ensure_key_value_pairs_logged(errors, output)
        end

        def ensure_key_value_pairs_logged(hash, output)
          hash.each do |k,v|
            expect(output).to include "#{k}=#{v}"
          end
        end
      end

      context 'for all other bodies' do
        let(:body) { 'error' }
        let(:result) { HyperionResult.new(route, HyperionStatus::CLIENT_ERROR, 500, body) }
        it 'logs them' do
          output = capture_stdout do
            log_result(result)
          end
          expect(output).to include body
        end
      end
    end
  end

  def capture_stdout
    output = StringIO.new
    with_stdout(output) do
      yield
    end
    output.string
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
