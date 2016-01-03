#!/bin/bash

USER=${1:-root}
set -e -x
export DEBIAN_FRONTEND=noninteractive
SUDO_COMMAND=sudo

if [ 'root' == ${USER} ] && [ -z $(getent passwd ubuntu) ]; then
  USER=ubuntu
  useradd -m -G sudo ${USER} -s /bin/bash
  echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER}
  chmod 0440 /etc/sudoers.d/${USER}
  mkdir -p /home/${USER}/.ssh/
  cp ~/.ssh/authorized_keys /home/${USER}/.ssh/authorized_keys
  chown ubuntu:ubuntu /home/${USER}/.ssh/authorized_keys
else
  cd /home/${USER}
fi

PUPPET_HOME=/opt/puppetlabs
if [ -e ${PUPPET_HOME}/bin/puppet ]; then
  echo "This puppet theatre is ready!"
  exit 0
fi


su ${USER} <<EOF
sudo su -c "cd ~ && gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3"

wget https://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb -O /tmp/puppetlabs.deb
${SUDO_COMMAND} dpkg -i /tmp/puppetlabs.deb
${SUDO_COMMAND} apt-get update

${SUDO_COMMAND} apt-get install -y git-core build-essential libssl-dev zlib1g-dev puppet-agent

# Puppet needs the puppet group to exist. Pretty dumb
if [ -z `cat /etc/group | cut -f 1 -d':' | grep puppet` ]; then
  ${SUDO_COMMAND} groupadd puppet
fi

${SUDO_COMMAND} mkdir -p /srv/apps
${SUDO_COMMAND} chown ${USER}:root /srv/apps
if [ -z `cat /etc/profile | grep puppet` ]; then
  echo "export PATH=${PUPPET_HOME}/bin:$PATH" | ${SUDO_COMMAND} tee --append /etc/profile
fi
EOF

if [ 'root' != ${USER} ]; then
  cd -
fi

echo "Please reload your shell script if this is an interactive shell. Just run"
echo "source /etc/profile"

