require 'core_ext/string/camelize'
require 'core_ext/hash/deep_symbolize_keys'

module Travis
  class Worker
    class Receiver
      autoload :Amqp,   'travis/worker/receiver/amqp'
      autoload :Http,   'travis/worker/receiver/http'
      autoload :Legacy, 'travis/worker/receiver/legacy'
      autoload :Stub,   'travis/worker/receiver/stub'

      class << self
        def create(config)
          const_get(config[:receiver].to_s.camelize, false).new(config)
        end
      end

      include Helpers::Crypt

      attr_reader :config, :runner

      def initialize(config)
        @config = config
      end

      def run(job)
        job = normalize(job)
        reporting(job) do |reporter|
          const = Runner.const_get(config[:runner].to_s.camelize, false)
          @runner = const.new(job, reporter)
          runner.run
        end
      rescue Exception => e
        puts e.message, e.backtrace
        exit
      end

      def stop
        runner.stop if runner
      end

      private

        def reporting(job)
          const = Reporter.const_get(config[:reporter].to_s.camelize, false)
          reporter = const.new(job, config)
          reporter.start
          yield reporter
          sleep 2
          reporter.stop
        end

        def normalize(job)
          job = job.deep_symbolize_keys
          job[:lang] ||= 'ruby'
          job[:repo_key] = decrypt(decode(job[:repo_key])) if job[:repo_key]
          job
        end
    end
  end
end
