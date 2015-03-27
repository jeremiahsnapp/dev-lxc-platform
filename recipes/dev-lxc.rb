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

ruby_block "add WORKING_CONTAINER to PS1" do
  block do
    rc = Chef::Util::FileEdit.new("/root/.bashrc")
    rc.insert_line_if_no_match(/^PS1='.*WORKING_CONTAINER/, %q(PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w ($WORKING_CONTAINER)\$ '))
    rc.write_file
  end
end
