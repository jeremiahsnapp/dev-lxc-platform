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
