#!/bin/bash

if ! test -f `which chef-solo`; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install ruby1.9.3
    gem install chef
fi &&

chef-solo -c chef/solo.rb -j chef/solo.json
