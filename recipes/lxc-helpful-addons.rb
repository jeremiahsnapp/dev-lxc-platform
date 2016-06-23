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

execute 'update resolv.conf' do
  command '/sbin/resolvconf -u'
  action :nothing
end

cookbook_file '/etc/resolvconf/resolv.conf.d/head' do
  source 'resolvconf-head'
  notifies :run, 'execute[update resolv.conf]'
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
