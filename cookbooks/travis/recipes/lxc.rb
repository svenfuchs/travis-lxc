user  = 'travis'
group = 'travis'
home  = "/home/#{user}"
key   = "/home/#{user}/.ssh/id_rsa.pub"
langs = %w(ruby)

package 'libyaml-dev'

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

bash 'chown home dir' do
  code "chown -R travis:travis #{home}"
end

# this would rather go into the ruby container ... or something.
include_recipe 'rvm::user'
# include_recipe 'ci_environment::travis_build_environment'
