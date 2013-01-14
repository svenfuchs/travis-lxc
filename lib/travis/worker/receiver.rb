require 'core_ext/string/camelize'
require 'core_ext/hash/deep_symbolize_keys'

module Travis
  class Worker
    class Receiver
      autoload :Amqp, 'travis/worker/receiver/amqp'
      autoload :Http, 'travis/worker/receiver/http'
      autoload :Stub, 'travis/worker/receiver/stub'

      include Utils::Crypt

      attr_reader :config, :runner

      def initialize(config)
        @config = config
      end

      def stop
        runner.stop if runner
      end

      private

        def run(job)
          job = normalize(job)
          reporting(job) do |reporter|
            const = Runner.const_get(config[:runner].to_s.camelize, false)
            @runner = const.new(job, reporter)
            @runner.run
          end
        rescue Exception => e
          puts e.message, e.backtrace
          raise e
        end

        def reporting(job)
          const = Reporter.const_get(config[:reporter].to_s.camelize, false)
          reporter = const.new(job, config)
          yield reporter
          sleep 2
          reporter.stop
        end

        def normalize(job)
          job = job.deep_symbolize_keys
          job[:repo_key] = decrypt(decode(job[:repo_key])) if job[:repo_key]
          job
        end
    end
  end
end
