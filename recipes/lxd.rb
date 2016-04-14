apt_repository 'ubuntu-lxc' do
  uri 'http://ppa.launchpad.net/ubuntu-lxc/lxd-stable/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key '7635B973'
end

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
