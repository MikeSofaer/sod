#! /bin/bash
# Install build essential
set -ex
apt-get -y install curl
apt-get -y install git-core

/etc/sod/rvm_install.sh
rvm package install zlib
rvm package install openssl
rvm package install readline
rvm install $RUBY_VERSION #-C --with-zlib-dir=/usr/local/rvm/usr --with-readline-dir=/usr/local/rvm/usr --with-openssl-dir=/usr/local/rvm/usr

export PATH=/usr/local/rvm/rubies/$RUBY_VERSION/bin:/usr/local/rvm/gems/$RUBY_VERSION/bin:$PATH

gem install chef
echo 'cookbook_path "/etc/sod/cookbooks"' > /etc/sod/solo.rb

echo '{"recipes": ["sod::default"]}' > /etc/sod/cookbooks/sod/sod.json
chef-solo -c /etc/sod/solo.rb -j /etc/sod/cookbooks/sod/sod.json

echo '{"recipes": ["sod::project_chef"]}' > /etc/sod/cookbooks/sod/project_chef.json
chef-solo -c /etc/sod/solo.rb -j /etc/sod/cookbooks/sod/project_chef.json
