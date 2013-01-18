require 'multi_json'
require 'hot_bunnies'

module Travis
  class Worker
    class Reporter
      class Amqp < Reporter
        def report(type, data)
          key = job[:routing_keys][type] || raise("undefined routing_key for #{type}")
          type, data = normalize(type, data)
          data = MultiJson.encode(data.merge(id: job[:id]))

          puts "report #{type}: #{data}"
          exchange.publish(data, properties: { type: type }, routing_key: key)
        end

        def stop
          super
          channel.close
          connection.close
        end

        private

          def normalize(type, data)
            type = "job:#{data.delete(:event)}" if type == :state # TODO unfuck hub message handling
            [type, data]
          end

          def exchange
            @exchange ||= channel.exchange('reporting', type: :topic, durable: true)
          end

          def channel
            @channel ||= connection.create_channel
          end

          def connection
            @connection ||= HotBunnies.connect(config[:amqp])
          end
      end
    end
  end
end
