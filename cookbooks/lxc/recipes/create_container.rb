name  = 'ruby'
root  = "/var/lib/lxc/#{name}/rootfs"
user  = 'travis'
group = 'travis'
home  = "#{root}/home/#{user}"
key   = "/home/#{user}/.ssh/id_rsa.pub"

# creating a container in the base box would make sense because then the rootfs
# would already be cached at /var/cache/lxc/quantal/rootfs-i386 and creating
# rootfs' would go much, much faster.

bash 'create container' do
  code   "lxc-create -t ubuntu -n #{name}"
  not_if "lxc-ls | grep #{name}"
end

bash 'create group' do
  code   "chroot #{root} groupadd #{group}"
  not_if "chroot #{root} cat /etc/group | grep ^#{group}:"
end

bash 'create user' do
  code   "chroot #{root} useradd #{user} -g #{group} --create-home -s /bin/bash"
  not_if "chroot #{root} cat /etc/passwd | grep ^#{user}:"
end

bash 'authorize ssh key' do
  code   "mkdir -p #{home}/.ssh && cp #{key} #{home}/.ssh/authorized_keys"
  creates "#{home}/.ssh/authorized_keys"
end

bash 'chown home dir' do
  code "chroot #{root} chown -R #{user}:#{group} /home/#{user}"
end

cookbook_file "#{root}/etc/sudoers" do
  source 'sudoers'
end
