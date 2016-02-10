service 'lxc-net' do
  action [:enable, :start]
end

cookbook_file '/etc/default/lxc-net' do
  source 'lxc-net'
  notifies :restart, 'service[lxc-net]'
end

cookbook_file '/etc/lxc/dnsmasq.conf' do
  source 'dnsmasq.conf'
  notifies :restart, 'service[lxc-net]'
end

cookbook_file '/etc/lxc/dhcp-hosts.conf' do
  source 'dhcp-hosts.conf'
  action :create_if_missing
  notifies :restart, 'service[lxc-net]'
end

cookbook_file '/etc/lxc/addn-hosts.conf' do
  source 'addn-hosts.conf'
  action :create_if_missing
  notifies :restart, 'service[lxc-net]'
end

directory '/usr/local/share/lxc/hooks' do
  recursive true
end

cookbook_file '/usr/local/share/lxc/hooks/clone-etc-hosts' do
  source 'clone-etc-hosts'
  mode 00755
end

# This provides the dhcp_release tool
package 'dnsmasq-utils'

cookbook_file '/usr/local/share/lxc/hooks/post-stop-dhcp-release' do
  source 'post-stop-dhcp-release'
  mode 00755
end

cookbook_file '/etc/lxc/default.conf' do
  source 'lxc-default.conf'
end

cookbook_file '/etc/profile.d/lxc-helpers.sh' do
  source 'lxc-helpers.sh'
end

ruby_block "add WORKING_CONTAINER to PS1" do
  block do
    rc = Chef::Util::FileEdit.new("/root/.bashrc")
    rc.insert_line_if_no_match(/^PS1='.*WORKING_CONTAINER/, %q(PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w ($WORKING_CONTAINER)\$ '))
    rc.write_file
  end
end

cookbook_file '/usr/local/bin/containers-view' do
  source 'containers-view'
  owner 'root'
  group 'root'
  mode 0755
end

cookbook_file '/etc/bash_completion.d/dev-lxc' do
  source 'bash-completion-dev-lxc'
  owner 'root'
  group 'root'
  mode 0755
end
