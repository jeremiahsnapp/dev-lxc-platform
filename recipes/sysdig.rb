include_recipe 'apt'

package "linux-headers-#{node['kernel']['release']}"

include_recipe 'sysdig'
