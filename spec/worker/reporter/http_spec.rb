require 'spec_helper'

RSpec::Matchers.define :report_http do |type = nil, data = nil|
  match do |action|
    expectation = Net::HTTP.expects(:post_form)
    type ? expectation.with(uris[type], data) : expectation.never
    failure_message_for_should do
      "expected a report to http for: #{type.inspect}, #{data.inspect}"
    end
    action.call
  end
end

describe Travis::Worker::Reporter::Http do
  let(:uris)      { Hash[*job[:urls].map { |key, value| [key, URI.parse(value)] }.flatten] }
  let(:job)       { { urls: { log: 'log_endpoint', state: 'state_endpoint' }, buffer: 0, uuid: '1234' } }
  let(:config)    { {} }
  let(:reporter)  { described_class.new(job, config) }

  before :each do
    Net::HTTP.stubs(:post_form)
  end

  def expect_report(type, data)
    Net::HTTP.expects(:post_form).with(uris[type], data)
  end

  it 'reports log output' do
    reporter << 'some build output'
    -> { reporter.flush }.should report_http(:log, log: 'some build output', number: 0, uuid: '1234')
  end

  it 'reports a started build' do
    reporter << '[travis:build:start]'
    -> { reporter.flush }.should report_http(:state, event: :start, started_at: Time.now, worker: 'hostname', uuid: '1234')
    reporter.flush
  end

  it 'reports a successful build if the previous state is :finish' do
    reporter << '[travis:script:finish]'
    reporter << '[travis:build:finish]'
    -> { reporter.flush }.should report_http(:state, event: :finish, state: :passed, finished_at: Time.now, uuid: '1234')
    reporter.flush
  end

  it 'reports an errored build if the previous state is :start' do
    reporter << '[travis:install:start]'
    reporter << '[travis:build:finish]'
    -> { reporter.flush }.should report_http(:state, event: :finish, state: :errored, error: :install_failed, finished_at: Time.now, uuid: '1234')
    reporter.flush
  end

  it 'reports a final log message on build finish' do
    reporter << '[travis:build:finish]'
    -> { reporter.flush }.should report_http(:log, final: true, number: 0, uuid: '1234')
    reporter.flush
  end

  # TODO can't get this matcher to behave
  xit 'does not report anything for starting build stages for now' do
    reporter << '[travis:install:finish]'
    -> { reporter.flush }.should_not report_http
  end
end
