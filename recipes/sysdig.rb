package "linux-headers-#{node['kernel']['release']}"

include_recipe 'sysdig'
# the following is necessary because of this bug in the sysdig cookbook
# https://github.com/jarosser06/chef-sysdig/issues/12
edit_resource(:apt_repository, 'sysdig') do
  distribution false
end

# `apt-get install -q -y sysdig-0.14.0` fails with the following error even though
# i've confirmed the draios repository and key are properly configured
# "The following packages cannot be authenticated"
# adding this option circumvents the issue until i find a better solution
edit_resource(:package, 'sysdig') do
  options '--allow-unauthenticated'
end
