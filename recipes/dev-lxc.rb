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

ruby_block 'enable bash completion' do
  block do
    rc = Chef::Util::FileEdit.new('/root/.bashrc')
    rc.insert_line_if_no_match(/^\s+\. \/etc\/bash_completion/, "if [ -f /etc/bash_completion ] && ! shopt -oq posix; then\n    . /etc/bash_completion\nfi")
    rc.write_file
  end
end

cookbook_file '/usr/local/bin/cluster-view' do
  source 'cluster-view'
  owner 'root'
  group 'root'
  mode 0755
end
