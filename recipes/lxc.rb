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
