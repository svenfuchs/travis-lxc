module Travis
  class Worker
    class Runner
      class Vbox < Runner
        def run
          vm.sandboxed do
            super
          end
          exit
        end

        def cmd
          "ssh 127.0.0.1 -p #{vm.ssh_port} -l vagrant -i ./keys/vagrant -- #{super}"
        end

        def vm
          @vm ||= Vm::Vbox.new(Vm::Vbox.machine_names.first)
        end
      end
    end
  end
end

