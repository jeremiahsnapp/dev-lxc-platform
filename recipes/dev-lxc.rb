include_recipe 'build-essential'

package 'lxc-dev'

include_recipe 'ruby-install'
ruby_install_ruby 'ruby 2.1.2'

include_recipe 'chruby_install'

gem_package 'dev-lxc' do
  gem_binary '/opt/rubies/ruby-2.1.2/bin/gem'
  action :upgrade
end

ruby_block "alias dev-lxc" do
  block do
    rc = Chef::Util::FileEdit.new("/root/.bashrc")
    rc.insert_line_if_no_match(/^alias dl=dev-lxc$/, "alias dl=dev-lxc")
    rc.write_file
  end
end
