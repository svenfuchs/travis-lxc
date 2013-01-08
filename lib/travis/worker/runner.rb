module Travis
  class Worker
    class Runner
      autoload :Lxc,  'travis/worker/runner/lxc'
      autoload :Stub, 'travis/worker/runner/stub'
      autoload :Vbox, 'travis/worker/runner/vbox'

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
    end
  end
end
