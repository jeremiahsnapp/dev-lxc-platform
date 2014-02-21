apt_repository 'ubuntu-lxc' do
  uri 'http://ppa.launchpad.net/ubuntu-lxc/daily/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key '7635B973'
end

package 'lxc'

service 'lxc-net' do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end

# yum is required for creating centos containers
package 'yum'
