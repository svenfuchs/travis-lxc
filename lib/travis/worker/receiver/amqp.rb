require 'hot_bunnies'
require 'multi_json'

module Travis
  class Worker
    class Receiver
      class Amqp < Receiver
        include Legacy

        attr_reader :subscription

        def start
          @subscription = subscribe(&method(:run))
        end

        def stop
          subscription.cancel
          channel.close
          connection.close
        end

        def run(headers, data)
          super(MultiJson.decode(data))
          headers.ack
        rescue Exception => e
          puts e.message, e.backtrace
        end

        private

          def subscribe(&block)
            queue.subscribe(ack: true, blocking: false, &block)
          end

          def queue
            @queue = channel.queue(config[:amqp][:queue], durable: true)
          end

          def channel
            @channel ||= connection.create_channel.tap do |channel|
              channel.prefetch = 1
            end
          end

          def connection
            @connection ||= HotBunnies.connect(config[:amqp])
          end
      end
    end
  end
end
