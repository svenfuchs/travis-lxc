module Travis
  class Worker
    class Receiver
      # fakes receiving jobs, useful for testing/dev
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
            buffer: 0.1,
            timeout: {
              build: 1800,
              log: 300
            }
          }
        end
      end
    end
  end
end
