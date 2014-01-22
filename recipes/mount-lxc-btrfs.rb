directory '/btrfs/lxclib'
directory '/var/lib/lxc'
mount '/var/lib/lxc' do
  device '/btrfs/lxclib'
  fstype 'none'
  options 'bind'
  pass 0
  action [:mount, :enable]
end

directory '/btrfs/lxccache'
directory '/var/cache/lxc'
mount '/var/cache/lxc' do
  device '/btrfs/lxccache'
  fstype 'none'
  options 'bind'
  pass 0
  action [:mount, :enable]
end
