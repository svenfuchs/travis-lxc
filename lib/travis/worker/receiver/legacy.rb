module Travis
  class Worker
    class Receiver
      module Legacy
        def normalize(msg)
          super(
            id: msg[:job][:id],
            urls: {
              script: "#{config[:api_endpoint]}/jobs/#{msg[:job][:id]}/build.sh",
            },
            routing_keys: {
              state: 'reporting.jobs.builds',
              log:   'reporting.jobs.logs'
            },
            buffer: 0.25,
            timeouts: {
              build: 25 * 60,
              log: 5 * 60
            },
            max_length: 1 * 1024 * 1024,
            # repo_key: Base64.encode64(File.read(File.expand_path('.ssh/id_rsa.repo')))
          )
        end
      end
    end
  end
end

