require 'rspec'
require 'travis/worker'

HOSTNAME.replace('hostname')

RSpec.configure do |c|
  c.mock_framework = :mocha

  c.before :each do
    @now = Time.now
    Time.stubs(:now).returns(@now)
  end
end
