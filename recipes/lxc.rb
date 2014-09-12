if node['platform'] == 'ubuntu' && node['platform_version'].to_f == 12.04
  apt_repository 'ubuntu-lxc' do
    uri 'http://ppa.launchpad.net/ubuntu-lxc/stable/ubuntu'
    distribution node['lsb']['codename']
    components ['main']
    keyserver 'keyserver.ubuntu.com'
    key '7635B973'
  end
end

package 'lxc' do
  action :upgrade
end

package 'lxc-templates' do
  action :upgrade
end

service 'lxc-net' do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end

# yum is required for creating centos containers
package 'yum'
