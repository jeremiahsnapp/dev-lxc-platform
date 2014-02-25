include_recipe 'build-essential'

node.default['rbenv']['group_users'] = ['root', 'vagrant']

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby "2.1.0" do
  global true
end

package 'lxc-dev'

rbenv_gem 'ruby-lxc' do
  ruby_version '2.1.0'
end

git '/usr/local/src/dev-lxc' do
  repository 'https://github.com/jeremiahsnapp/dev-lxc.git'
end

rbenv_execute 'gem-build-dev-lxc' do
  ruby_version '2.1.0'
  cwd '/usr/local/src/dev-lxc'
  command 'gem build dev-lxc.gemspec'
  creates 'dev-lxc-0.1.0.gem'
end

gem_package 'gem-lxc' do
  gem_binary '/opt/rbenv/versions/2.1.0/bin/gem'
  source '/usr/local/src/dev-lxc/dev-lxc-0.1.0.gem'
  options '--no-ri --no-rdoc'
end
