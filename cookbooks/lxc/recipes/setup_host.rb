package 'lxc'

user  = 'travis'
group = 'travis'
home  = '/home/travis'
key   = "#{home}/.ssh/id_rsa"

bash 'create group' do
  code   "groupadd #{group}"
  not_if "cat /etc/group | grep ^#{group}:"
end

bash 'create user' do
  code "useradd #{user} -g #{group} --create-home -s /bin/bash"
  not_if "cat /etc/passwd | grep ^#{user}:"
end

bash 'generate ssh key' do
  code "rm #{key}*; ssh-keygen -t rsa -q -v -f #{key} -P ''"
  user user
  group group
  creates key
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
