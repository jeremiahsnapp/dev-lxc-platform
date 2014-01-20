directory '/btrfs/lxclib'
directory '/btrfs/lxccache'

mount '/var/lib/lxc' do
  device '/btrfs/lxclib'
  fstype 'none'
  options 'bind'
  pass 0
  action [:mount, :enable]
end

mount '/var/cache/lxc' do
  device '/btrfs/lxccache'
  fstype 'none'
  options 'bind'
  pass 0
  action [:mount, :enable]
end
