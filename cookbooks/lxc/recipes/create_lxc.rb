root  = '/var/lib/lxc/base/rootfs'
user  = 'travis'
group = 'travis'
home  = "#{root}/home/#{user}"
key   = "/home/#{user}/.ssh/id_rsa.pub"
langs = %w(ruby)

# http://tickets.opscode.com/browse/CHEF-2812
bash 'add group' do
  code   "chroot #{root} groupadd #{group}"
  not_if "chroot #{root} grep ^#{group}: /etc/group"
end

bash 'add user' do
  code   "chroot #{root} useradd #{user} -g #{group} --create-home -s /bin/bash"
  not_if "chroot #{root} grep ^#{user}: /etc/passwd"
end

bash 'authorize ssh key' do
  code    "mkdir -p #{home}/.ssh && cp #{key} #{home}/.ssh/authorized_keys"
  creates "#{home}/.ssh/authorized_keys"
end

bash 'chown home dir' do
  code "chroot #{root} chown -R #{user}:#{group} /home/#{user}"
end

cookbook_file "#{root}/etc/sudoers" do
  source 'sudoers'
end

langs.each do |lang|
  bash 'lxc: clone base container' do
    code   "lxc-clone -o base -n #{lang}"
    not_if "lxc-ls | grep #{lang}"
  end
end
