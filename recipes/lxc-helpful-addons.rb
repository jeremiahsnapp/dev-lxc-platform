service 'lxc-net' do
  action [:enable, :start]
end

cookbook_file '/etc/default/lxc-net' do
  source 'lxc-net'
end

cookbook_file '/etc/lxc/dnsmasq.conf' do
  source 'dnsmasq.conf'
end

cookbook_file '/etc/lxc/dhcp-hosts.conf' do
  source 'dhcp-hosts.conf'
  action :create_if_missing
end

cookbook_file '/etc/lxc/addn-hosts.conf' do
  source 'addn-hosts.conf'
  action :create_if_missing
end

# restart lxc-net
service 'lxc-net' do
  action :restart
end

# restarting systemd-resolved.service updates /etc/resolv.conf AND /run/systemd/resolve/resolv.conf
service 'systemd-resolved.service' do
  action :nothing
end

cookbook_file '/etc/resolvconf/resolv.conf.d/head' do
  source 'resolvconf-head'
  notifies :restart, 'service[systemd-resolved.service]', :immediately
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

cookbook_file '/etc/lxc/default.conf' do
  source 'lxc-default.conf'
end
