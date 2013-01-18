#!/bin/bash

if ! test -f `which chef-solo`; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install ruby1.9.3 make git-core
    gem install chef
    git clone https://github.com/travis-ci/travis-cookbooks.git
fi &&

chef-solo -c chef/lxc/solo.rb -j chef/lxc/solo.json
