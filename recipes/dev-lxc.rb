include_recipe 'build-essential'

package 'lxc-dev'

include_recipe 'ruby-install'
ruby_install_ruby 'ruby 2.1.2' do
  gems [ { name: 'dev-lxc' } ]
end

include_recipe 'chruby_install'

ruby_block "alias dev-lxc" do
  block do
    rc = Chef::Util::FileEdit.new("/root/.bashrc")
    rc.insert_line_if_no_match(/^alias dl=dev-lxc$/, "alias dl=dev-lxc")
    rc.write_file
  end
end
