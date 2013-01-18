require 'spec_helper'

class TestReceiver < Struct.new(:config)
  include Module.new { def normalize(job); job; end }
  include Travis::Worker::Receiver::Legacy
end

describe Travis::Worker::Receiver::Legacy do

  let(:payload)  { eval(File.read('spec/support/payloads/legacy.rb')) }
  let(:receiver) { TestReceiver.new(api_endpoint: 'http://api.travis-ci.org') }

  describe 'normalize' do
    it 'normalizes a legacy amqp payload' do
      receiver.normalize(payload).should == {
        id: 385899,
        urls: { script: 'http://api.travis-ci.org/jobs/385899/build.sh' },
        routing_keys: { state: 'reporting.jobs.builds', log: 'reporting.jobs.logs' },
        buffer: 0.25,
        timeouts: { build: 1500, log: 300 },
        max_length: 1048576
      }
    end
  end
end
