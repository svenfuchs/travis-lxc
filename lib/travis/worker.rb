require 'core_ext/string/camelize'

STDOUT.sync = true
HOSTNAME = `hostname`

module Travis
  class Worker
    autoload :Receiver, 'travis/worker/receiver'
    autoload :Runner,   'travis/worker/runner'
    autoload :Reporter, 'travis/worker/reporter'

    attr_reader :config, :receivers

    def initialize(config)
      @config    = config
      @receivers = []
    end

    def start
      1.upto(config[:threads]) do
        receivers << Receiver.const_get(config[:receiver].to_s.camelize, false).new(config)
      end
      sleep
    end
  end
end

app = Travis::Worker.new(
  threads: 1,
  receiver: :stub,
  reporter: :stub
)
app.start
