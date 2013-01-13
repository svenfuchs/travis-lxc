module Travis
  class Worker
    class Reporter
      class Amqp < Reporter
        def report(type, data)
          # report to amqp
        end

        # @reporting_channel ||= broker_connection.create_channel
        # # these are declared here mostly to aid development purposes. MK
        # reporting_channel = broker_connection.create_channel
        # reporting_channel.queue("reporting.jobs.builds", :durable => true)
        # reporting_channel.queue("reporting.jobs.logs",   :durable => true)
      end
    end
  end
end
