require 'core_ext/string/camelize'

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

      def run(job)
        reporting do |reporter|
          const = Runner.const_get(config[:runner].to_s.camelize, false)
          const.new(job, reporter).run
        end
      rescue => e
        puts e.message, e.backtrace
        raise e
      end

      def reporting
        const = Reporter.const_get(config[:reporter].to_s.camelize, false)
        reporter = const.new(job)
        yield reporter
        sleep 2
        reporter.stop
      end
    end
  end
end
