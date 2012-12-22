#!/bin/sh

set -e

if [ -e /usr/local/bin/puppet ]; then
  echo This puppet theatre is ready!
  exit 0
fi

RUBY_VERSION=1.9.1

sudo apt-get update

sudo apt-get install -y git-core ruby$RUBY_VERSION ruby$RUBY_VERSION-dev \
                        rubygems$RUBY_VERSION irb$RUBY_VERSION ri$RUBY_VERSION rdoc$RUBY_VERSION \
                        build-essential libopenssl-ruby$RUBY_VERSION libssl-dev zlib1g-dev libicu48

sudo update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby$RUBY_VERSION 400 \
                         --slave   /usr/share/man/man1/ruby.1.gz ruby.1.gz \
                                   /usr/share/man/man1/ruby$RUBY_VERSION.1.gz \
                         --slave   /usr/bin/ri ri /usr/bin/ri$RUBY_VERSION \
                         --slave   /usr/bin/irb irb /usr/bin/irb$RUBY_VERSION \
                         --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc$RUBY_VERSION

sudo update-alternatives --install /usr/bin/gem gem /usr/bin/gem$RUBY_VERSION 400

sudo update-alternatives --config ruby
sudo update-alternatives --config gem

echo Finally... installing puppet
sudo gem sources -u
sudo gem install puppet -v 3.0.1 --no-ri --no-rdoc
sudo gem install bundler -v 1.2.3 --no-ri --no-rdoc

# Puppet needs the puppet group to exist. Pretty dumb
if [ -z `cat /etc/group | cut -f 1 -d':' | grep puppet` ]; then
  sudo groupadd puppet
fi