module Travis
  class Worker
    class Jobs
      def pop
        # POST jobs/pop?queues
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
