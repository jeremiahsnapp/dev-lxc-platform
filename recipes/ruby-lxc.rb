include_recipe 'build-essential'

package 'lxc-dev'

node.default['rbenv']['group_users'] = ['root', 'vagrant']

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby "2.1.0" do
  global true
end

rbenv_gem 'ruby-lxc' do
  ruby_version '2.1.0'
end
