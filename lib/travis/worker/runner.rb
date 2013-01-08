module Travis
  class Worker
    class Runner
      autoload :Lxc,  'travis/worker/reporter/lxc'
      autoload :Stub, 'travis/worker/reporter/stub'
      autoload :Vbox, 'travis/worker/reporter/vbox'

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
