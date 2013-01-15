user   = 'travis'
group  = 'travis'
home   = '/home/travis'
key    = "#{home}/.ssh/id_rsa"
rootfs = '/var/lib/lxc/base/rootfs'

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

bash 'authorize ssh key' do
  code    "mkdir -p #{rootfs}#{home}/.ssh && cp #{key}.pub #{rootfs}#{home}/.ssh/authorized_keys"
  creates "#{rootfs}#{home}/.ssh/authorized_keys"
end

cookbook_file '/usr/local/bin/tlimit' do
  source 'bin/tlimit'
  mode 0755
end

bash 'chown home dir' do
  code "chroot #{rootfs} chown -R travis:travis #{home}"
end

cookbook_file "#{rootfs}/etc/sudoers" do
  source 'sudoers'
end

directory "#{rootfs}/etc/chef"
directory "#{rootfs}/var/chef"

bash 'copy cookbooks' do
  code "cp -pr /tmp/vagrant-chef-1/chef-solo-1/* #{rootfs}/var/chef/"
end

cookbook_file "#{rootfs}/etc/chef/solo.rb" do
  source 'chef/solo.rb'
end

cookbook_file "#{rootfs}/etc/chef/solo.json" do
  source 'chef/solo.json'
end

bash 'run chef' do
  code "chroot #{rootfs} /opt/ruby/bin/chef-solo -c /etc/chef/solo.rb -j /etc/chef/solo.json"
end

