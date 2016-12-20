include_recipe 'apt'

apt_package 'ruby' do
  options '--auto-remove'
  action :purge
end

execute "Setup ChefDK as default ruby" do
  command "echo 'eval \"$(chef shell-init bash)\"' >> /root/.bashrc"
  user "root"
  environment( { "HOME" => "/root" } )
  not_if "grep 'chef shell-init' /root/.bashrc"
end

include_recipe 'dev-lxc-platform::byobu'

include_recipe 'dev-lxc-platform::helpful-addons'

include_recipe 'dev-lxc-platform::sysdig'

include_recipe 'dev-lxc-platform::btrfs'

include_recipe 'dev-lxc-platform::mount-lxc-btrfs'

include_recipe 'dev-lxc-platform::mount-lxd-btrfs'

include_recipe 'dev-lxc-platform::lxd'

include_recipe 'dev-lxc-platform::lxc-helpful-addons'

include_recipe 'dev-lxc-platform::dev-lxc'
