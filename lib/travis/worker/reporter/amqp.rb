module Travis
  class Worker
    class Reporter
      class Amqp < Reporter
        def report(type, data)
          # report to amqp
        end
      end
    end
  end
end
