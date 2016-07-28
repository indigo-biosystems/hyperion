require 'logatron/logatron'

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

Logatron.configure do |c|
  c.logger = Logger.new(ENV['VERBOSE'] == 'true' ? $stdout : '/dev/null')
  c.level = Logatron::DEBUG
  c.transformer = proc {|x| x[:body]}
end
