#!/bin/bash

if ! test -f `which chef-solo`; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install ruby1.9.3 make
    gem install chef

fi &&

chef-solo -c chef/host/solo.rb -j chef/host/solo.json
