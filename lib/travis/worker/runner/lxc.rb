module Travis
  class Worker
    class Runner
      class Lxc < Local
        def cmd
          "sudo lxc-start-ephemeral -o #{job[:lang]} -u travis -S #{SSH_KEY} -- '#{super}'"
        end
      end
    end
  end
end
