require 'net/http'
require 'uri'

module Travis
  class Worker
    class Reporter
      EVENTS = /\[travis:([^:]+):(start|finish)(?::result=([\d]+))?\]\n/m

      attr_reader :job, :queue, :targets, :last_stage, :last_state

      def initialize(job)
        @job = job
        @queue = Queue.new
        @thread = Thread.new { loop { flush } }

        @targets = {
          log:   URI.parse(job[:urls][:log]),
          state: URI.parse(job[:urls][:state])
        }
        @number = 0
      end

      def <<(logs)
        queue << logs
      end

      def flush
        data = ''
        data << queue.pop until queue.empty?
        report data
        sleep job[:buffer] || 0.5
      rescue => e
        puts e.message, e.backtrace
        raise e
      end

      def report(data)
        data.gsub!(EVENTS) { event($1, $2, $3); '' }
        log(data) if @started && !data.empty?
      end

      def log(log)
        post targets[:log], log: log, number: @number
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
        post targets[:state], event: :start, started_at: Time.now, worker: HOSTNAME
      end

      def on_finish(result)
        state = last_state == 'start' ? :errored : (result == 0 ? :passed : :failed)
        data = { event: :finish, state: state, finished_at: Time.now }
        data[:error] = :"#{last_stage}_failed" if state == :errored
        post targets[:state], data
      end

      def post(target, data)
        Net::HTTP.post_form(target, data)
      end

      def stop
        @thread.exit
      end
    end
  end
end
