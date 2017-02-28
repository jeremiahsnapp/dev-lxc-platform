include_recipe 'build-essential'

package 'lxc-dev'

execute 'install dev-lxc gem' do
  command 'chef gem install dev-lxc'
  user 'root'
  environment({ 'HOME' => '/root' })
end

cookbook_file '/etc/bash_completion.d/dev-lxc' do
  source 'bash-completion-dev-lxc'
  owner 'root'
  group 'root'
  mode 0755
end

ruby_block 'alias dev-lxc' do
  block do
    rc = Chef::Util::FileEdit.new('/root/.bashrc')
    rc.insert_line_if_no_match(/^alias dl=dev-lxc$/, 'alias dl=dev-lxc')
    rc.write_file
  end
end

cookbook_file '/usr/local/bin/cluster-view' do
  source 'cluster-view'
  owner 'root'
  group 'root'
  mode 0755
end
