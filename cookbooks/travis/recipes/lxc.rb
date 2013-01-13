root  = '/var/lib/lxc/base/rootfs'
user  = 'travis'
group = 'travis'
home  = "#{root}/home/#{user}"
key   = "/home/#{user}/.ssh/id_rsa.pub"
langs = %w(ruby)

user user do
  home "/home/#{user}"
  shell "/bin/bash"
end

bash 'set password' do
  code "echo #{user}:#{user} | chpasswd"
end

group group do
  members [user]
end

cookbook_file '/usr/local/bin/tlimit' do
  source 'bin/tlimit'
  mode 0755
end

# this would rather go into the ruby container ... or something.
include_recipe 'rvm::user'

# why the hell does this fail
langs.each do |lang|
  bash "clone base container to #{lang}" do
    code   "lxc-clone -o base -n #{lang}"
    not_if "lxc-ls | grep #{lang}"
  end
end
