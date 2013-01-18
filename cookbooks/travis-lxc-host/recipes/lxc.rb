user  = 'travis'
group = 'travis'
rootfs = '/var/lib/lxc/base/rootfs'
home  = "/home/#{user}"
key   = "/home/#{user}/.ssh/id_rsa.pub"
langs = %w(ruby)

bash 'create group' do
  code   "chroot #{rootfs} groupadd --system #{group}"
  not_if "chroot #{rootfs} grep ^#{group}: /etc/group"
end

bash 'create user' do
  code   "chroot #{rootfs} useradd -s /bin/bash -d /home/#{user} -g #{group} -m #{user}"
  not_if "chroot #{rootfs} grep ^#{user}: /etc/passwd"
end

bash 'set password' do
  code "chroot #{rootfs} echo #{user}:#{user} | chpasswd"
end

cookbook_file "#{rootfs}/etc/sudoers" do
  source 'sudoers'
end

bash 'lxc: authorize ssh key' do
  code    "mkdir -p #{rootfs}#{home}/.ssh && cp #{key} #{rootfs}#{home}/.ssh/authorized_keys"
  creates "#{rootfs}#{home}/.ssh/authorized_keys"
end

bash 'chown home dir' do
  code "chroot #{rootfs} chown -R travis:travis #{home}"
end

cookbook_file "#{rootfs}/usr/local/bin/killtree" do
  source 'bin/killtree'
  mode 0755
end

cookbook_file "#{rootfs}/usr/local/bin/tlimit" do
  source 'bin/tlimit'
  mode 0755
end

langs.each do |lang|
  bash "clone base container to #{lang}" do
    code   "lxc-clone -o base -n #{lang}"
    not_if "lxc-ls | grep #{lang}"
  end
end

