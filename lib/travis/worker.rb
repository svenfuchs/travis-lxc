require 'core_ext/hash/deep_symbolize_keys'
require 'yaml'

STDOUT.sync = true
HOSTNAME = `hostname`

module Travis
  class Worker
    autoload :Helpers,  'travis/worker/helpers'
    autoload :Receiver, 'travis/worker/receiver'
    autoload :Runner,   'travis/worker/runner'
    autoload :Reporter, 'travis/worker/reporter'
    autoload :Vm,       'travis/worker/vm'

    attr_reader :config, :receivers

    def initialize(config = nil)
      @config    = config || YAML.load_file('config/worker.yml').deep_symbolize_keys
      @receivers = []
    end

    def start
      1.upto(config[:threads]) do
        receiver = Receiver.create(config)
        receivers << receiver
        receiver.start
      end
      sleep
    end

    def stop
      receivers.each { |receiver| receiver.stop }
    end
  end
end
