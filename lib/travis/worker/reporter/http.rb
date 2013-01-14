module Travis
  class Worker
    class Reporter
      class Http < Reporter
        def report(type, data)
          # data.merge!(uuid: Travis.uuid)
          Net::HTTP.post_form(targets[type], data)
        end

        def targets
          @targets ||= {
            log:   URI.parse(job[:urls][:log]),
            state: URI.parse(job[:urls][:state])
          }
        end
      end
    end
  end
end
