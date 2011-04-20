#! /bin/bash
set -ex
# RVM dependencies
/usr/bin/aptitude install build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libxml2-dev libxslt-dev autoconf libc6-dev -y
#/usr/bin/yum install build-essential bison openssl libreadline6 libreadline6-devel curl git-core zlib1g zlib1g-devel libssl-devel libxml2-devel libxslt-devel autoconf libc6-devel -y

/etc/sod/rvm_install.sh
rvm install $RUBY_VERSION

export PATH=/usr/local/rvm/rubies/$RUBY_VERSION/bin:/usr/local/rvm/gems/$RUBY_VERSION/bin:$PATH

gem install chef --no-rdoc --no-ri
echo 'cookbook_path "/etc/sod/cookbooks"' > /etc/sod/solo.rb

echo '{"recipes": ["sod::default"]}' > /etc/sod/cookbooks/sod/sod.json
chef-solo -c /etc/sod/solo.rb -j /etc/sod/cookbooks/sod/sod.json

echo '{"recipes": ["sod::project_chef"]}' > /etc/sod/cookbooks/sod/project_chef.json
chef-solo -c /etc/sod/solo.rb -j /etc/sod/cookbooks/sod/project_chef.json
