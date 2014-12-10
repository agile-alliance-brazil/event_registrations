#!/bin/bash
set -e -x
export DEBIAN_FRONTEND=noninteractive
wget -O server_bootstrap.sh https://raw.github.com/agile-alliance-brazil/event_registrations/master/puppet/script/server_bootstrap.sh
chmod +x server_bootstrap.sh
./server_bootstrap.sh `whoami`