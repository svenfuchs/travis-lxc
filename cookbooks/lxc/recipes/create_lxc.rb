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

# install git, curl, make, gcc
# install rvm
#   curl -L https://get.rvm.io | bash -s stable --ruby
#   need to copy stuff from .bash_profile to .bashrc?
# install build-essential openssl libreadline6 libreadline6-dev zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config
# install bundler
