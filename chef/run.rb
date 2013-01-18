
# directory "#{rootfs}/etc/chef"
# directory "#{rootfs}/var/chef"
#
# bash 'copy cookbooks' do
#   code "cp -pr /tmp/vagrant-chef-1/chef-solo-1/* #{rootfs}/var/chef/"
# end
#
# cookbook_file "#{rootfs}/etc/chef/solo.rb" do
#   source 'chef/solo.rb'
# end
#
# cookbook_file "#{rootfs}/etc/chef/solo.json" do
#   source 'chef/solo.json'
# end
#
# git "#{rootfs}/var/chef/cookbooks/travis-cookbooks" do
#   repository 'https://github.com/travis-ci/travis-cookbooks.git'
#   reference 'master'
#   action :sync
# end

# bash 'run chef' do
#   code "chroot #{rootfs} /opt/ruby/bin/chef-solo -c /etc/chef/solo.rb -j /etc/chef/solo.json"
# end



