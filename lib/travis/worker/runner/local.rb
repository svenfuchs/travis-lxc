module Travis
  class Worker
    class Runner
      # runs a build script locally, useful for testing/dev
      class Local < Runner
        def cmd
          curl  = "curl -s --retry 20 --retry-max-time 600 --max-time 10 #{job[:urls][:script]}"
          echo  = "echo 'echo could not retrieve build script from #{job[:urls][:script]}'"
          limit = "tlimit -b #{job[:timeouts][:build]} -l #{job[:timeouts][:log]} -m #{job[:max_length]}"
          bash  = "bash --login -s"
          "(#{curl} || #{echo}) | #{limit} -- #{bash} 2>&1"
          # "(#{curl} || #{echo}) | #{bash} 2>&1"
        end
      end
    end
  end
end

