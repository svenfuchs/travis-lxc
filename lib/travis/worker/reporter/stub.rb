module Travis
  class Worker
    class Reporter
      class Stub < Reporter
        def report(type, data)
          puts "report #{type}: #{data}"
        end
      end
    end
  end
end
