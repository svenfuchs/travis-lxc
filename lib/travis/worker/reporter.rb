require 'thread'
require 'net/http'
require 'uri'

module Travis
  class Worker
    class Reporter
      autoload :Amqp, 'travis/worker/reporter/amqp'
      autoload :Http, 'travis/worker/reporter/http'
      autoload :Stub, 'travis/worker/reporter/stub'

      EVENTS = /\[travis:([^:]+):(start|finish)(?::result=([\d]+))?\]\n?/m

      attr_reader :job, :config, :queue, :last_stage, :last_state, :number

      def initialize(job, config)
        @job    = job
        @config = config
        @queue  = Queue.new
        @number = 0
      end

      def start
        @thread = Thread.new { loop { flush } }
      end

      def <<(logs)
        queue << logs
      end

      def flush
        data = ''
        data << queue.pop until queue.empty?
        data.gsub!(EVENTS) { event($1.to_sym, $2.to_sym, $3.to_i); '' }
        log(data) if !data.empty? # @started &&
        sleep job[:buffer] || 0.5
      rescue Exception => e
        puts e.message, e.backtrace
      end

      def stop
        @thread.exit
      end

      private

        def log(log)
          log.gsub! %r(^.*bin/tlimit.*Killed.*$), '' # hrm, can't silence kill
          # TODO log = Coder.clean(data[:log])
          report :log, log: log, number: number, uuid: job[:uuid]
          @number += 1
        end

        def event(stage, state, result)
          # puts [stage, state, result].compact.join(':')
          if stage == :build && state == :start
            on_start
          elsif stage == :build && state == :finish
            on_finish(result)
          else
            @last_stage, @last_state = stage, state
          end
        end

        def on_start
          @started = true
          report :state, event: :start, started_at: Time.now, worker: HOSTNAME, uuid: job[:uuid]
        end

        def on_finish(result)
          report :log, final: true, number: number, uuid: job[:uuid]
          state = last_state == :start ? :errored : (result == 0 ? :passed : :failed)
          data = { event: :finish, state: state, finished_at: Time.now, uuid: job[:uuid] }
          data[:error] = :"#{last_stage}_failed" if state == :errored
          report :state, data
        end
    end
  end
end
