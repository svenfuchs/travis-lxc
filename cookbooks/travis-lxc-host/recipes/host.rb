user   = 'travis'
group  = 'travis'
home   = '/home/travis'
key    = "#{home}/.ssh/id_rsa"

package 'libyaml-dev'
package 'git-core'

cookbook_file "/root/.ssh/config" do
  source 'ssh_config'
  mode 0644
end

user user do
  home "/home/#{user}"
  shell "/bin/bash"
  supports manage_home: true
end

bash 'set password' do
  code "echo #{user}:#{user} | chpasswd"
end

group group do
  members [user]
end

directory "#{home}/.ssh" do
  action :create
  mode 0755
  owner user
  group group
end

cookbook_file "#{home}/.ssh/config" do
  source 'ssh_config'
  mode 0644
  owner user
  group group
end

bash 'generate ssh key' do
  code "rm #{key}*; ssh-keygen -t rsa -q -v -f #{key} -P ''"
  user user
  group group
  creates key
end

bash 'chown home dir' do
  code "chown -R travis:travis #{home}"
end

cookbook_file '/usr/local/bin/tlimit' do
  source 'bin/tlimit'
  mode 0755
end

cookbook_file "/etc/sudoers" do
  source 'sudoers'
end
