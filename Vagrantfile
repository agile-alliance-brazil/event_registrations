# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :
HERE = File.dirname(__FILE__)
APP_DIR = HERE.freeze
INFRA_DIR = "#{HERE}/puppet"

Vagrant.configure('2') do |config|
  # Production is Ubuntu 14.04 in an AWS micro instance/Digital Ocean basic droplet so is our Vagrant box
  config.vm.box     = 'ubuntu/trusty64'
  config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box'
  config.vm.provider :virtualbox do |vm|
    vm.memory = 2048
    vm.cpus = 2
  end
  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.auto_detect = true
    # If you are using VirtualBox, you might want to enable NFS for shared folders
    config.cache.enable_nfs  = true
  end
  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_update = true
    config.vbguest.no_remote = true
  end

  # We want to use the same ruby version that production will use
  config.vm.provision :shell do |s|
    s.path = "#{INFRA_DIR}/script/server_bootstrap.sh"
    s.args = 'vagrant'
  end

  config.ssh.insert_key = false
  config.ssh.private_key_path = "#{APP_DIR}/certs/insecure_private_key"

  config.vm.define :deploy do |vm_config|
    vm_config.vm.network :private_network, ip: '10.11.12.14'
    vm_config.vm.network :forwarded_port, id: 'ssh', guest: 22, host: 2203
    vm_config.vm.network :forwarded_port, guest: 80, host: 8081
  end
end
