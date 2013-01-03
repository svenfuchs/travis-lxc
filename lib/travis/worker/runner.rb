require 'thread'
require 'open3'

module Travis
  class Worker
    class Runner
      SSH_KEY = '/home/travis/.ssh/id_rsa'

      attr_reader :jobs, :job, :reporter

      def initialize(jobs)
        @jobs = jobs
        @thread = Thread.new { loop { run } }
      end

      def run
        @job = jobs.pop
        job ? start : sleep(1)
      rescue => e
        puts e.message, e.backtrace
        raise e
      end

      def start
        @reporter = Reporter.new(job)
        execute
        sleep 2
        reporter.stop
      end

      def cmd
        # 'ruby -e "STDOUT.sync = true; puts %([travis:build:start]); 1.upto(20) { |i| puts i; sleep(0.25) }; puts %([travis:build:finish:result=1])"'
        lxc  = "lxc-start-ephemeral -o #{job[:lang]} -u travis -S #{SSH_KEY}"
        curl = "curl -s --retry 20 --retry-max-time 600 --max-time 10 #{job[:urls][:script]}"
        echo = "echo 'echo could not retrieve build script from #{job[:urls][:script]}'"
        "#{lxc} -- '(#{curl} || #{echo}) | bash --login -s 2>&1'"
      end

      def execute
        Open3.popen3(cmd) do |_, out|
          out.each_char do |char|
            reporter << char
          end
        end
      end
    end
  end
end
