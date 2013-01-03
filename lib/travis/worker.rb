require 'thread'
require 'open3'
require 'shellwords'
require 'net/http'
require 'uri'

STDOUT.sync = true
HOSTNAME = `hostname`

module Travis
  class Worker
    autoload :Jobs,     'travis/worker/jobs'
    autoload :Runner,   'travis/worker/runner'
    autoload :Reporter, 'travis/worker/reporter'

    attr_reader :config, :jobs, :runners

    def initialize(config)
      @config  = config
      @jobs    = Jobs.new
      @runners = []
    end

    def start
      1.upto(config[:threads]) do
        runners << Runner.new(jobs)
      end
      sleep
    end
  end
end

app = Travis::Worker.new(threads: 1)
app.start
