directory '/btrfs/lxclib'
directory '/var/lib/lxc'
mount '/var/lib/lxc' do
  device '/btrfs/lxclib'
  fstype 'none'
  options 'bind'
  pass 0
  action [:mount, :enable]
  not_if "mount -t btrfs | grep -q ' on /var/lib/lxc .*,subvol=/lxclib'"
end
