require 'open3'

module Travis
  class Worker
    class Runner
      autoload :Local, 'travis/worker/runner/local'
      autoload :Lxc,   'travis/worker/runner/lxc'
      autoload :Vbox,  'travis/worker/runner/vbox'

      SSH_KEY = '/home/travis/.ssh/id_rsa'

      attr_reader :job, :reporter

      def initialize(job, reporter)
        @job = job
        @reporter = reporter
      end

      def run
        Open3.popen3(cmd) do |_, out|
          out.each_char do |char|
            reporter << char
          end
        end
      end

      def watcher
        @watcher ||= Watcher.build(timeouts: job[:timeouts], max_length: job[:max_length])
      end
    end
  end
end
