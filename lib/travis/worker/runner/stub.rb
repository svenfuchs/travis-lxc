module Travis
  class Worker
    class Runner
      class Stub < Runner
        def cmd
          # 'ruby -e "STDOUT.sync = true; puts %([travis:build:start]); 1.upto(20) { |i| puts i; sleep(0.25) }; puts %([travis:build:finish:result=1])"'
          curl = "curl -s --retry 20 --retry-max-time 600 --max-time 10 #{job[:urls][:script]}"
          echo = "echo 'echo could not retrieve build script from #{job[:urls][:script]}'"
          "(#{curl} || #{echo}) | bash --login -s 2>&1"
        end
      end
    end
  end
end

