require 'open3'

module Travis
  class Worker
    class Runner
      class Lxc < Runner
        def cmd
          lxc  = "sudo lxc-start-ephemeral -o #{job[:lang]} -u travis -S #{SSH_KEY}"
          curl = "curl -s --retry 20 --retry-max-time 600 --max-time 10 #{job[:urls][:script]}"
          echo = "echo 'echo could not retrieve build script from #{job[:urls][:script]}'"
          "#{lxc} -- '(#{curl} || #{echo}) | bash --login -s 2>&1'"
        end
      end
    end
  end
end
