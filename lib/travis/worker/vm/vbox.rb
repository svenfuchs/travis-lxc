# The Java System property vbox.home needs to be setup to use the vboxjxpcom.jar library.
# This can either be done via the command line using:
#
#   $ruby -J-Dvbox.home=/Applications/VirtualBox.app/Contents/MacOS script_to_run.rb
#
# or by setting:
#
#   ENV["VBOX_HOME"] = "/Applications/VirtualBox.app/Contents/MacOS")
#
# You may need to make /dev/vboxdrv accessible by the current user, either by chmoding the file
# or by adding the user to the group assigned to the file.

$: << File.expand_path('../../../../../vendor/virtualbox-4.2.6r82870', __FILE__)

require 'core_ext/object/retrying'
require 'java'

java_import 'java.util.List'
java_import 'java.util.Arrays'
java_import 'java.io.BufferedReader'
java_import 'java.io.InputStreamReader'

unless java.lang.System.getProperty('vbox.home')
  java.lang.System.setProperty('vbox.home', ENV['VBOX_HOME'] || raise("ENV['VBOX_HOME'] needs to be set"))
end

require 'vboxjxpcom.jar'

java_import 'org.virtualbox_4_2.VirtualBoxManager'
java_import 'org.virtualbox_4_2.VBoxEventType'
java_import 'org.virtualbox_4_2.LockType'
java_import 'org.virtualbox_4_2.MachineState'
java_import 'org.virtualbox_4_2.IMachineStateChangedEvent'
java_import 'org.virtualbox_4_2.DeviceType'
java_import 'org.virtualbox_4_2.AccessMode'
java_import 'org.virtualbox_4_2.MediumType'
java_import 'org.virtualbox_4_2.SessionState'

module Travis
  class Worker
    module Vm
      class Vbox
        class VmNotFound < StandardError
          def initialize(name)
            super("VirtualBox VM #{name} could not be found")
          end
        end

        class VmFatalError < StandardError
          def initialize
            'The VM had trouble shutting down and has been forcefully killed, your build will be requeued shortly.'
          end
        end

        class VmSshPortNotFound < StandardError
          def initialize(name)
            super("Could not find SSH port for the VM #{name}")
          end
        end

        # include Retryable, Logging

        class << self
          def manager
            @manager ||= VirtualBoxManager.create_instance(nil)
          end

          def machine_names
            @machine_names ||= machines.map(&:name)
          end

          def machine(name)
            machines.detect { |m| m.name == name } || raise(VmNotFound, name)
          end

          def machines
            manager.vbox.machines
          end
        end

        attr_reader :name

        def initialize(name)
          # @name = "travis-#{name}"
          @name = name
        end

        def sandboxed
          prepare
          start_sandbox
          yield
        rescue Exception => e
          puts "#{name}: #{e.message}", e.backtrace
        ensure
          close_sandbox
        end

        def prepare
          if requires_snapshot?
            puts "Preparing vm #{name} ..."
            restart { immutate }
            wait_for_boot
            pause
            snapshot
          end
          true
        end

        def ssh_port
          max_network_adapters.times do |i|
            machine.get_network_adapter(i).nat_engine.redirects.each do |redirect|
              parts = redirect.split(',')
              return parts[3] if parts.first == 'ssh'
            end
          end
          raise VmSshPortNotFound
        end

        private

          def manager
            self.class.manager
          end

          def machine
            @machine ||= self.class.machine(name)
          end

          def pid
            lines = `ps aux | grep #{name}`.split("\n")
            lines.size == 3 ? lines.first.split[1] : nil
          end

          def start_sandbox
            power_off unless powered_off?
            rollback
            power_on
          end

          def close_sandbox
            power_off unless powered_off?
          rescue org.virtualbox_4_2.VBoxException
            `kill -9 #{pid}`
            raise VmFatalError
          end

          def requires_snapshot?
            machine.snapshot_count == 0
          end

          def running?
            machine.state == MachineState::Running
          end

          def powered_off?
            machine.state == MachineState::PoweredOff ||
              machine.state == MachineState::Aborted ||
              machine.state == MachineState::Saved
          end

          def power_on
            with_session(false) do |session|
              machine.launch_vm_process(session, 'headless', '')
            end
            puts "#{name} started with process id : #{pid}"
          end

          def power_off
            with_session do |session|
              session.console.power_down
            end
          end

          def restart
            power_off if running?
            yield if block_given?
            power_on
          end

          def pause
            with_session do |session|
              session.console.pause
            end
          end

          def snapshot
            with_session do |session|
              session.console.take_snapshot('sandbox', "#{machine.get_name} sandbox snapshot taken at #{Time.now.utc}")
            end
            sleep(3) # this makes sure the snapshot is finished and ready
          end

          def rollback
            with_session do |session|
              session.console.restore_snapshot(machine.current_snapshot)
            end
          end

          def max_network_adapters
            machine.parent.system_properties.get_max_network_adapters(machine.chipset_type)
          end

          def immutate
            return if immutable?
            attachment = sata_medium_attachment
            controller = attachment.controller
            detach_device(controller)

            path = attachment.medium.location.to_s
            medium = manager.vbox.open_medium(path, DeviceType::HardDisk, AccessMode::ReadWrite, false)
            medium.type = MediumType::Immutable
            attach_device(controller, medium)
          end

          def immutate
            return if immutable?

            if attachment = sata_medium_attachment
              controller_name = attachment.controller
              medium_path     = attachment.medium.location.to_s
              detach_device(controller_name)

              medium = manager.vbox.open_medium(medium_path, DeviceType::HardDisk, AccessMode::ReadWrite, false)
              medium.type = MediumType::Immutable
              attach_device(controller_name, medium)
            else
              raise 'Can not immutate disk because the attachment could not be found.'
            end
          end

          def immutable?
            attachment = sata_medium_attachment
            attachment && attachment.medium.type == MediumType::Immutable
          end

          def sata_medium_attachment
            machine.medium_attachments.detect { |ma| ma.controller =~ /SATA/ }
          end

          def detach_device(controller_name)
            with_session do |session|
              session.machine.detach_device(controller_name, 0, 0)
              session.machine.save_settings
            end
          end

          def attach_device(controller_name, medium)
            with_session do |session|
              session.machine.attach_device(controller_name, 0, 0, DeviceType::HardDisk, medium)
              session.machine.save_settings
            end
          end

          def wait_for_boot
            retrying times: 3 do
              system("ssh 127.0.0.1 -p #{ssh_port} -l vagrant -i ./keys/vagrant -- echo vm started")
            end
            sleep(10) # make sure the vm has some time to start other services
          end

          def with_session(lock = true)
            session = manager.session_object
            lock_machine(session) if lock
            progress = yield(session)
            progress.wait_for_completion(-1) if progress
            sleep(0.5)
          ensure
            unlock_machine(session)
          end

          def lock_machine(session)
            unlock_machine(session)
            machine.lock_machine(session, LockType::Shared)
          end

          def unlock_machine(session)
            if session
              puts "#{name} session in #{session.state} state"
              session.unlock_machine if session.state == SessionState::Locked
            end
          end
      end
    end
  end
end
