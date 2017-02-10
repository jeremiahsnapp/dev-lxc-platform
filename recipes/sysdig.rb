include_recipe 'apt'

package "linux-headers-#{node['kernel']['release']}"

include_recipe 'sysdig'
# the following is necessary because of this bug in the sysdig cookbook
# https://github.com/jarosser06/chef-sysdig/issues/12
edit_resource(:apt_repository, 'sysdig') do
  distribution false
end
