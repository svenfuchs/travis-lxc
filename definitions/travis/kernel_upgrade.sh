# see https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1021471
# and https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1065434

echo "deb http://archive.ubuntu.com/ubuntu/ quantal-proposed restricted main multiverse universe" >> /etc/apt/sources.list
apt-get update
aptitude safe-upgrade --assume-yes

ls -al
