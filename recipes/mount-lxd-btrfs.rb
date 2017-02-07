directory '/btrfs/lxdlib'
directory '/var/lib/lxd'
mount '/var/lib/lxd' do
  device '/btrfs/lxdlib'
  fstype 'none'
  options 'bind'
  pass 0
  action [:enable, :mount]
  not_if "mount -t btrfs | grep -q ' on /var/lib/lxd .*,subvol=/lxdlib'"
end
