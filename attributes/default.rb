# usually you should use /dev/sdb for a vagrant instance and /dev/xvdb for an ec2 instance
# the default is empty to avoid unintentionally formatting the wrong disk
default['dev-lxc-platform']['btrfs_device'] = ''
