package 'btrfs-tools'

execute 'mkfs' do
  command "mkfs.btrfs #{node['dev-lxc-platform']['btrfs_device']}"
  not_if "(btrfs check #{node['dev-lxc-platform']['btrfs_device']} || grep -qs /btrfs /proc/mounts)"
end

directory '/btrfs'

mount '/btrfs' do
  device node['dev-lxc-platform']['btrfs_device']
  fstype 'btrfs'
  pass 0
  action [:mount, :enable]
end
