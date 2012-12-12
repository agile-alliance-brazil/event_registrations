# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  # Production is Ubuntu 12.04 so is our Vagrant box
  config.vm.box     = "quantal64"
  config.vm.box_url = "https://github.com/downloads/roderik/VagrantQuantal64Box/quantal64.box"

  # We want to use the same ruby version that production will use
  #config.vm.provision :shell, :path => "#{INFRA_DIR}/script/server_bootstrap.sh"
  config.vm.forward_port 80, 8081

  config.vm.provision :puppet, :module_path => "puppet/modules" do |puppet|
  	puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file = "vagrant.pp"
  end
end
