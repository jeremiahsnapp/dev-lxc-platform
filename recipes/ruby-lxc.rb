include_recipe 'build-essential'

package 'lxc-dev'

node.default['ruby_install']['version'] = '0.3.4'
include_recipe 'ruby_install'

ruby_install_ruby 'ruby 2.1.0'

node.default[:chruby_install][:default_ruby] = 'ruby-2.1.0'
include_recipe 'chruby_install'

git '/usr/local/src/ruby-lxc' do
  repository 'https://github.com/lxc/ruby-lxc.git'
end

execute 'gem-build-ruby-lxc' do
  command '/opt/rubies/ruby-2.1.0/bin/gem build ruby-lxc.gemspec'
  cwd '/usr/local/src/ruby-lxc'
  not_if { ::File.exists?('/usr/local/src/ruby-lxc/ruby-lxc-0.1.0.gem') }
end

gem_package 'ruby-lxc' do
  gem_binary '/opt/rubies/ruby-2.1.0/bin/gem'
  source '/usr/local/src/ruby-lxc/ruby-lxc-0.1.0.gem'
  options '--no-ri --no-rdoc'
end
