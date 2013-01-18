require 'base64'

module Travis
  class Worker
    class Receiver
      # fakes receiving jobs, useful for testing/dev
      class Stub < Receiver
        attr_reader :thread

        def initialize(*)
          super
        end

        def start
          @thread = Thread.new { loop { run(job) } }
        end

        def stop
          thread.exit
        end

        private

          def job
            {
              id: 1804637,
              lang: 'ruby',
              urls: {
                script: 'http://192.168.2.100:3000/jobs/1804637/build.sh',
                log:    'http://192.168.2.100:3000/jobs/1804637/log',
                state:  'http://192.168.2.100:3000/jobs/1804637/state'
              },
              routing_keys: {
                state: 'reporting.jobs.builds',
                log:   'reporting.jobs.logs'
              },
              buffer: 0.1,
              timeouts: {
                build: 25 * 60,
                log: 5 * 60
              },
              max_length: 1 * 1024 * 1024,
              repo_key: Base64.encode64(File.read(File.expand_path('.ssh/id_rsa.repo')))
            }
          rescue Exception => e
            puts e.message, e.backtrace
          end
      end
    end
  end
end
