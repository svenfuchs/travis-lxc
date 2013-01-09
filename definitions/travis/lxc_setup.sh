sudo -s

apt-get install --assume-yes lxc
lxc-create -t ubuntu -n base

rootfs=/var/lib/lxc/base/rootfs
ruby=ruby-1.9.3-p286
rubygems=rubygems-1.8.24

mkdir -p $rootfs/opt
cp -pr /opt/ruby $rootfs/opt/ruby
echo 'PATH=$PATH:/opt/ruby/bin/' > $rootfs/etc/profile.d/system_ruby.sh
HOME= chroot $rootfs /opt/ruby/bin/gem install chef --no-ri --no-rdoc

# chroot $rootfs
#
# # since this is the same as vagrant already does on the base box
# # can we just copy stuff to the chroot dir?
#
# wget http://ftp.ruby-lang.org/pub/ruby/1.9/$ruby.tar.gz
# tar xvzf $ruby.tar.gz
# cd $ruby
# ./configure --prefix=/opt/ruby
# make
# make install
# cd ..
# rm -rf $ruby*
#
# wget http://production.cf.rubygems.org/rubygems/$rubygems.tgz
# tar xzf $rubygems.tgz
# cd $rubygems
# /opt/ruby/bin/ruby setup.rb
# cd ..
# rm -rf $rubygems*
#
# /opt/ruby/bin/gem install chef --no-ri --no-rdoc
#
# echo 'PATH=$PATH:/opt/ruby/bin/' > $rootfs/etc/profile.d/system_ruby.sh
