include_recipe 'build-essential'

package 'lxc-dev'

execute "Setup ChefDK as default ruby" do
  command "chef shell-init bash >> /root/.bashrc"
  user "root"
  environment( { "HOME" => "/root" } )
  not_if "grep 'PATH=.*chefdk' /root/.bashrc"
end

execute "install dev-lxc gem" do
  command "chef gem install dev-lxc"
  user "root"
  environment( { "HOME" => "/root" } )
end

ruby_block "alias dev-lxc" do
  block do
    rc = Chef::Util::FileEdit.new("/root/.bashrc")
    rc.insert_line_if_no_match(/^alias dl=dev-lxc$/, "alias dl=dev-lxc")
    rc.write_file
  end
end

cookbook_file '/usr/local/bin/cluster-view' do
  source 'cluster-view'
  owner 'root'
  group 'root'
  mode 0755
end
