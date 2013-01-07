module Travis
  class Worker
    class Receiver
      class Stub < Receiver
        def initialize(*)
          super
          @thread = Thread.new { loop { run(job) } }
        end

        def job
          {
            lang: 'ruby',
            urls: {
              script: 'http://192.168.2.100:3000/jobs/1804637/build.sh',
              log:    'http://192.168.2.100:3000/jobs/1804637/log',
              state:  'http://192.168.2.100:3000/jobs/1804637/state'
            },
            buffer: 0.1
          }
        end
      end
    end
  end
end
