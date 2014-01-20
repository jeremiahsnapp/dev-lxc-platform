include_recipe 'build-essential'

package 'lxc-dev'

node.default['rbenv']['group_users'] = ['root', 'vagrant']

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby "2.1.0"

git '/usr/local/src/ruby-lxc' do
  repository 'https://github.com/lxc/ruby-lxc.git'
end

rbenv_execute 'gem-build-ruby-lxc' do
  ruby_version '2.1.0'
  cwd '/usr/local/src/ruby-lxc'
  command 'gem build ruby-lxc.gemspec'
  creates 'ruby-lxc-0.1.0.gem'
end

gem_package 'ruby-lxc' do
  gem_binary '/opt/rbenv/versions/2.1.0/bin/gem'
  source '/usr/local/src/ruby-lxc/ruby-lxc-0.1.0.gem'
  options '--no-ri --no-rdoc'
end
