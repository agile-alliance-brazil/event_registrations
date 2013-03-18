#!/bin/sh

set -e

if [ -e /usr/local/bin/puppet ]; then
  echo This puppet theatre is ready!
  exit 0
fi

sudo apt-get update

sudo apt-get install -y git-core ruby1.9 ruby1.9.1-dev \
                        rubygems1.9 irb1.9 ri1.9 rdoc1.9 \
                        build-essential libopenssl-ruby1.9.1 \
                        libssl-dev zlib1g-dev libicu48 \
                        ruby-odbc-dbg ruby-odbc

sudo update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.3 400 \
                         --slave   /usr/share/man/man1/ruby.1.gz ruby.1.gz \
                                   /usr/share/man/man1/ruby1.9.gz \
                         --slave   /usr/bin/ri ri /usr/bin/ri1.9.3 \
                         --slave   /usr/bin/irb irb /usr/bin/irb1.9.3 \
                         --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.3

sudo update-alternatives --install /usr/bin/gem gem /usr/bin/gem1.9.3 400

echo Finally... installing puppet
sudo gem sources -u
sudo gem install puppet -v 3.0.1 --no-ri --no-rdoc
sudo gem install bundler -v 1.2.4 --no-ri --no-rdoc

# Puppet needs the puppet group to exist. Pretty dumb
if [ -z `cat /etc/group | cut -f 1 -d':' | grep puppet` ]; then
  sudo groupadd puppet
fi

sudo mkdir -p /srv/apps
sudo chown ubuntu:root /srv/apps
