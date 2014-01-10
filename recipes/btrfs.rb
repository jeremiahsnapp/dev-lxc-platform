package 'btrfs-tools'

execute 'mkfs' do
  command 'mkfs.btrfs /dev/sdb'
  not_if '(btrfs check /dev/sdb || grep -qs /btrfs /proc/mounts)'
end

directory '/btrfs'

mount '/btrfs' do
  device '/dev/sdb'
  fstype 'btrfs'
  pass 0
  action [:mount, :enable]
end
