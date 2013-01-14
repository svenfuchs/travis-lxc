require 'multi_json'
require 'hot_bunnies'

module Travis
  class Worker
    class Reporter
      class Amqp < Reporter
        def report(type, data)
          # cleaned = Coder.clean(data[:log])
          data.merge!(id: job[:id]) # uuid: Travis.uuid
          data = MultiJson.encode(data: data) # TODO nesting could be removed
          key  = job[:routing_keys][type] || raise("undefined routing_key for #{type}")
          type = :job if type == :state # that's what hub expects
          exchanges[type].publish(data, properties: { type: type }, routing_key: key)
          # puts "report #{type}: #{data}"
        end

        def stop
          super
          exchanges.each { |_, exchange| exchange.channel.close }
          connection.close
        end

        private

          def exchanges
            @exchanges ||= Hash[*[:state, :log].map { |type| [type, create_exchange] }.flatten]
          end

          def create_exchange
            connection.create_channel.exchange('reporting', type: :topic, durable: true)
          end

          def connection
            @connection ||= HotBunnies.connect(config[:amqp])
          end
      end
    end
  end
end
