require 'thread'
require 'net/http'
require 'uri'

module Travis
  class Worker
    class Reporter
      autoload :Amqp, 'travis/worker/reporter/amqp'
      autoload :Http, 'travis/worker/reporter/http'
      autoload :Stub, 'travis/worker/reporter/stub'

      EVENTS = /\[travis:([^:]+):(start|finish)(?::result=([\d]+))?\]\n/m

      attr_reader :job, :queue, :last_stage, :last_state

      def initialize(job)
        @job = job
        @queue = Queue.new
        @thread = Thread.new { loop { flush } }
        @number = 0
      end

      def <<(logs)
        queue << logs
      end

      def flush
        data = ''
        data << queue.pop until queue.empty?
        data.gsub!(EVENTS) { event($1, $2, $3); '' }
        log(data) if @started && !data.empty?
        sleep job[:buffer] || 0.5
      rescue => e
        puts e.message, e.backtrace
        raise e
      end

      def log(log)
        report :log, log: log, number: @number
        @number += 1
      end

      def event(stage, state, result)
        puts [stage, state, result].compact.join(':')

        if stage == 'build' && state == 'start'
          on_start
        elsif stage == 'build' && state == 'finish'
          on_finish(result.to_i)
        else
          @last_stage, @last_state = stage, state
        end
      end

      def on_start
        @started = true
        report :state, event: :start, started_at: Time.now, worker: HOSTNAME
      end

      def on_finish(result)
        state = last_state == 'start' ? :errored : (result == 0 ? :passed : :failed)
        data = { event: :finish, state: state, finished_at: Time.now }
        data[:error] = :"#{last_stage}_failed" if state == :errored
        report :state, data
      end

      def stop
        @thread.exit
      end
    end
  end
end
