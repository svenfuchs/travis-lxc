module Travis
  class Worker
    class Receiver
      class Http < Receiver
        attr_reader :thread

        def initialize(*)
          super
        end

        def start
          @thread = Thread.new { loop { poll } }
        end

        def stop
          thread.exit
        end

        private

          def poll
            job = receive and run(job)
            sleep config[:poll_interval] || 5
          end

          def receive
            # poll an http api
          end
      end
    end
  end
end
