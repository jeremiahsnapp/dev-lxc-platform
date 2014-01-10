apt_repository 'ubuntu-lxc' do
  uri 'http://ppa.launchpad.net/ubuntu-lxc/daily/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key '7635B973'
end

package 'lxc'

# yum is required for creating centos containers
package 'yum'

directory '/btrfs/lxclib'
directory '/btrfs/lxccache'

mount '/var/lib/lxc' do
  device '/btrfs/lxclib'
  fstype 'none'
  options 'bind'
  pass 0
  action [:mount, :enable]
end

mount '/var/cache/lxc' do
  device '/btrfs/lxccache'
  fstype 'none'
  options 'bind'
  pass 0
  action [:mount, :enable]
end

service 'lxc-net' do
  provider Chef::Provider::Service::Upstart
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

directory '/usr/local/share/lxc/hooks' do
  recursive true
end

cookbook_file '/usr/local/share/lxc/hooks/clone-config-mount-entry' do
  source 'clone-config-mount-entry'
  mode 00755
end

cookbook_file '/usr/local/share/lxc/hooks/clone-etc-hosts' do
  source 'clone-etc-hosts'
  mode 00755
end

cookbook_file '/etc/lxc/default.conf' do
  source 'lxc-default.conf'
end
