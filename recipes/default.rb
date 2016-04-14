include_recipe 'apt'

include_recipe 'dev-lxc-platform::byobu'

include_recipe 'dev-lxc-platform::helpful-addons'

execute "Setup ChefDK as default ruby" do
  command "chef shell-init bash >> /root/.bashrc"
  user "root"
  environment( { "HOME" => "/root" } )
  not_if "grep 'PATH=.*chefdk' /root/.bashrc"
end
