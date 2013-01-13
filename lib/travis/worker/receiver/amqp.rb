require 'hot_bunnies'
require 'json'

module Travis
  class Worker
    class Receiver
      class Amqp < Receiver
        attr_reader :subscription

        def initialize(*)
          super
          @thread = Thread.new { loop { run(job) } }
          @subscription = subscribe(&method(:run))
        end

        def stop
          subscription.cancel
        end

        private

          def run(headers, msg)
            job = JSON.parse(msg)
            super(normalize(job))
            headers.ack
          rescue Exception => e
            puts e.message, e.backtrace
          end

          def subscribe(&block)
            queue.subscribe(ack: true, blocking: false, &block)
          end

          def queue
            @queue = channel.queue(config[:amqp][:queues][:builds], durable: true)
            # queue.bind(exchange, :routing_key => 'builds.common')
          end

          def channel
            @channel ||= connection.create_channel.tap do |channel|
              channel.prefetch = 1
            end
          end

          def connection
            @connection ||= HotBunnies.connect(config[:amqp])
          end

          def normalize(job)
            job
          end
      end
    end
  end
end
