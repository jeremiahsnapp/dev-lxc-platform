# -*- mode: ruby -*-
# # vi: set ft=ruby :

# The following Vagrant plugins are required
# vagrant-berkshelf
# vagrant-omnibus

dev_lxc_disk = File.expand_path("~/VirtualBox VMs/dev_lxc.vmdk")

Vagrant.configure("2") do |config|
  config.vm.box = "opscode-ubuntu-13.10"
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-13.10_chef-provisionerless.box"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--cpus", "4"]
    vb.customize ["modifyvm", :id, "--memory", "4096"]
    vb.customize ['createhd', '--filename', dev_lxc_disk, '--size', 40 * 1024]
    vb.customize ['storageattach', :id, '--storagectl', 'IDE Controller', '--port',
                  1, '--device', 0, '--type', 'hdd', '--medium', dev_lxc_disk]
  end

  config.vm.synced_folder "../downloads", "/downloads"

  config.berkshelf.enabled = true

  config.vm.network :private_network, ip: "33.33.34.13"

  config.omnibus.chef_version = :latest

  config.vm.provision :chef_solo do |chef|
    # chef.log_level = :debug
    chef.add_recipe "dev-lxc"
  end
end
