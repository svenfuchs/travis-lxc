require 'base64'
require 'open3'

module Travis
  class Worker
    class Runner
      autoload :Base, 'travis/worker/runner/base'
      autoload :Lxc,  'travis/worker/runner/lxc'
      autoload :Vbox, 'travis/worker/runner/vbox'

      include Utils::Crypt

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

      def stop
      end

      private

        def cmd
          copy  = "echo #{encode(job[:repo_key])} | base64 -d > ~/.ssh/id_rsa.repo" if job[:repo_key]
          curl  = "curl -s --retry 20 --retry-max-time 600 --max-time 10 #{job[:urls][:script]}"
          echo  = "echo 'echo could not retrieve build script from #{job[:urls][:script]}'"
          limit = "tlimit -b #{job[:timeouts][:build]} -l #{job[:timeouts][:log]} -m #{job[:max_length]}"
          bash  = "bash --login -s"
          [copy, "(#{curl} || #{echo}) | #{limit} -- #{bash} 2>&1"].compact.join('; ')
          # "(#{curl} || #{echo}) | #{bash} 2>&1"
        end
    end
  end
end
