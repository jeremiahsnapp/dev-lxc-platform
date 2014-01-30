apt_repository 'ubuntu-lxc' do
  uri 'http://ppa.launchpad.net/ubuntu-lxc/daily/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key '7635B973'
end

# this is needed as of lxc daily build 1/22/2014
# the package's preinstall script fails
# because /etc/lxc doesn't exist
# ref: https://bugs.launchpad.net/ubuntu/+source/lxc/+bug/1270961
directory '/etc/lxc'

package 'lxc'

service 'lxc-net' do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end

# yum is required for creating centos containers
package 'yum'
