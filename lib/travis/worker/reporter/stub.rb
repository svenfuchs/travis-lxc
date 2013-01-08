module Travis
  class Worker
    class Reporter
      # reports build output locally to stdout, useful for testing/dev
      class Stub < Reporter
        def report(type, data)
          puts "report #{type}: #{data}"
        end
      end
    end
  end
end
