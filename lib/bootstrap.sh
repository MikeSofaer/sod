#! /bin/bash
set -ex
# RVM dependencies
apt-get install build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libxml2-dev libxslt-dev autoconf libc6-dev -y
#rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-4.noarch.rpm || true
#/usr/bin/yum install gcc gcc-c++ kernel-devel patch make bison openssl libreadline6 libreadline6-devel curl git-core zlib1g zlib1g-devel libssl-devel libxml2-devel libxslt-devel autoconf libc6-devel -y

/etc/sod/rvm_install.sh
. /usr/local/lib/rvm >/dev/null
rvm install $RUBY_VERSION
rvm use $RUBY_VERSION

gem install chef --no-rdoc --no-ri
echo 'cookbook_path "/etc/sod/cookbooks"' > /etc/sod/solo.rb

echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

echo '{"recipes": ["sod::default"]}' > /etc/sod/cookbooks/sod/sod.json
chef-solo -c /etc/sod/solo.rb -j /etc/sod/cookbooks/sod/sod.json

echo '{"recipes": ["sod::project_chef"]}' > /etc/sod/cookbooks/sod/project_chef.json
chef-solo -c /etc/sod/solo.rb -j /etc/sod/cookbooks/sod/project_chef.json
