directory '/btrfs/dockerlib'
directory '/var/lib/docker'
mount '/var/lib/docker' do
  device '/btrfs/dockerlib'
  fstype 'none'
  options 'bind'
  pass 0
  action [:enable, :mount]
  not_if "mount -t btrfs | grep -q ' on /var/lib/docker .*,subvol=/dockerlib'"
end
