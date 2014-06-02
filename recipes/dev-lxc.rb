include_recipe 'build-essential'

node.default['rbenv']['group_users'] = ['root', 'vagrant']

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby "2.1.2" do
  global true
end

package 'lxc-dev'

rbenv_gem 'dev-lxc' do
  ruby_version '2.1.2'
end

ruby_block "alias dev-lxc" do
  block do
    rc = Chef::Util::FileEdit.new("/root/.bashrc")
    rc.insert_line_if_no_match(/^alias dl=dev-lxc$/, "alias dl=dev-lxc")
    rc.write_file
  end
end
