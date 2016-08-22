package ['lxd', 'lxd-client', 'lxc', 'lxcfs', 'lxc-templates'] do
  action :upgrade
end

remote_file "/etc/bash_completion.d/lxd-client" do
  source "file:///usr/share/bash-completion/completions/lxc"
end

service 'lxc-net' do
  action [:enable, :start]
end

# yum is required for creating centos containers
package 'yum'
