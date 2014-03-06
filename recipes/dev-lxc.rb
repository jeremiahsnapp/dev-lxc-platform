include_recipe 'build-essential'

node.default['rbenv']['group_users'] = ['root', 'vagrant']

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby "2.1.0" do
  global true
end

package 'lxc-dev'

rbenv_gem 'dev-lxc' do
  ruby_version '2.1.0'
end
