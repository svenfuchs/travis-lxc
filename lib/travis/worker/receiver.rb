require 'core_ext/string/camelize'
require 'core_ext/hash/deep_symbolize_keys'

module Travis
  class Worker
    class Receiver
      autoload :Amqp, 'travis/worker/receiver/amqp'
      autoload :Http, 'travis/worker/receiver/http'
      autoload :Stub, 'travis/worker/receiver/stub'

      attr_reader :config

      def initialize(config)
        @config = config
      end

      private

        def run(job)
          job = job.deep_symbolize_keys
          reporting(job) do |reporter|
            const = Runner.const_get(config[:runner].to_s.camelize, false)
            const.new(job, reporter).run
          end
        rescue Exception => e
          puts e.message, e.backtrace
          raise e
        end

        def reporting(job)
          const = Reporter.const_get(config[:reporter].to_s.camelize, false)
          reporter = const.new(job)
          yield reporter
          sleep 2
          reporter.stop
        end
    end
  end
end
