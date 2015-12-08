directory '/btrfs/lxdlib'
directory '/var/lib/lxd'
mount '/var/lib/lxd' do
  device '/btrfs/lxdlib'
  fstype 'none'
  options 'bind'
  pass 0
  action [:mount, :enable]
end
