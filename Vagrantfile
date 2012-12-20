# -*- mode: ruby -*-
# vi: set ft=ruby :
HERE = File.dirname(__FILE__)
APP_DIR = "#{HERE}"

Vagrant::Config.run do |config|
  # Production is Ubuntu 12.04 so is our Vagrant box
  config.vm.box     = "quantal64"
  config.vm.box_url = "https://github.com/downloads/roderik/VagrantQuantal64Box/quantal64.box"
  config.vm.customize ["modifyvm", :id, "--memory", 1024]
  config.vm.customize ["modifyvm", :id, "--cpus", 4]

  # We want to use the same ruby version that production will use
  #config.vm.provision :shell, :path => "#{INFRA_DIR}/script/server_bootstrap.sh"

  config.vm.define :dev do |config|
    # Setting up a share so we can edit locally but run in vagrant
    config.vm.share_folder "current", "/srv/apps/registrations/current", "#{APP_DIR}"

    # Using default rack settings
    config.vm.forward_port 9292, 9292

    config.vm.provision :puppet, :module_path => "puppet/modules" do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "vagrant-dev.pp"
    end
  end

  config.vm.define :deploy do |config|
    # Using default rack settings
    config.vm.forward_port 80, 8081

    config.vm.provision :puppet, :module_path => "puppet/modules" do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "vagrant.pp"
    end
  end
end
