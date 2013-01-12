module Travis
  class Worker
    class Runner
      # runs a build script locally, useful for testing/dev
      class Stub < Runner
        def cmd
          curl = "curl -s --retry 20 --retry-max-time 600 --max-time 10 #{job[:urls][:script]}"
          echo = "echo 'echo could not retrieve build script from #{job[:urls][:script]}'"
          bash = "./bin/timeout --build #{job[:timeout][:build]} --log #{job[:timeout][:log]} bash --login -s"
          "(#{curl} || #{echo}) | #{bash} 2>&1"
        end
      end
    end
  end
end

