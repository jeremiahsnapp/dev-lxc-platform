# dev-lxc-platform Change Log

## 11.0.2 (2017-03-10)

* Update bash-completion-dev-lxc script

## 11.0.1 (2017-03-09)

* Use apt_update resource instead of apt cookbook's default recipe

## 11.0.0 (2017-03-08)

* Increase CPU count to 4
* Improve the hostname regex in bash completion script
* Install and configure tinyproxy
* Improve web proxy usage documentation

## 10.0.0 (2017-03-06)

* Remove dev-lxc alias
* Use dl command in create-base-container recipe
* Use dl command in cluster-view script
* Improve dev-lxc bash completion script
* Enable bash completion in .bashrc
* Change default vagrant synced_folders paths

## 9.1.5 (2017-03-06)

* Reduce number of Vagrant CPUs

## 9.1.4 (2017-03-02)

* Minor fix to kitchen-instance-ctl

## 9.1.3 (2017-03-02)

* Minor improvement to kitchen-instance-ctl

## 9.1.2 (2017-03-02)

* Use 'chef exec ruby' to run kitchen-instance-ctl
* Significant improvements to kitchen-instance-ctl script
  Instance names or regex can be used just like the kitchen command.
  'kitchen diagnose' is used under the hood so this script has access to all
  relevant instance info including EC2 region.

## 9.1.1 (2017-02-28)

* Cookbook style cleanup [\#6](https://github.com/jeremiahsnapp/dev-lxc-platform/pull/6) ([tas50](https://github.com/tas50))
* Add braces back to environment property since recent style cleanup accidentally removed them
* Properly specify root user in the 'Create base container' execute resource
* Add region and tags properties to .kitchen.yml [\#7](https://github.com/jeremiahsnapp/dev-lxc-platform/pull/7) ([irvingpop](https://github.com/irvingpop))

## 9.1.0 (2017-02-27)

* Preinstall chef-load

## 9.0.0 (2017-02-22)

* Improve dev-lxc-platform build docs
* Add docs about transferring files to EC2 instance
* Document that Berksfile.lock should be deleted when upgrading major version of dev-lxc-platform
* Allow unauthenticated sysdig package to install
* apt_repository can't identify key fingerprints when gnupg 2.1.x is used
* Use AWS credentials file instead of config file
* Comment out .kitchen.yml's vagrant instance
* Allow SSH to EC2 instance's root user
* Make kitchen-instance-ctl.bat work even if `chef shell-init powershell` has not been run

## 8.0.0 (2017-02-16)

* Improve docs
* Add kitchen-instance-ctl.bat file for Windows users
* Add private network back to Vagrant config
* Disable berks ssl verification
* Fix sysdig install bug
* Install docker
* Include apt::default and ntp::default recipes in dev-lxc-platform::default

## 7.0.1 (2017-02-09)

* Add mitmproxy alias to .bashrc

## 7.0.0 (2017-02-08)

* Update README.md
* Refactor BTRFS mounts and ensure they are idempotent
* Add create-base-containers recipe and attribute
* Use attribute to specify btrfs device
* Update .kitchen.yml so it works for EC2 and Vagrant instances
* Create kitchen-instance-ctl command to stop, start and get status of kitchen instances
* Remove .envrc file
* Install mitmproxy
* Restart services immediately. They might be needed later in the chef-client run
* Restart systemd-resolved.service to update resolv.conf files

## 6.0.1 (2016-12-20)

* Improve the way Chef DK is setup as default ruby

## 6.0.0 (2016-12-19)

* Use bento/ubuntu-16.10 Vagrant box for the host VM

## 5.0.1 (2016-11-28)

* Remove dhcp release post-stop hook

## 5.0.0 (2016-08-22)

* Use bento/ubuntu-16.04 Vagrant box for the host VM

## 4.0.2 (2016-07-20)

* Change default mount point from dev to work

## 4.0.1 (2016-06-24)

* Remove btrfs directory and mount of /var/lib/dev-lxc

## 4.0.0 (2016-06-23)

* Overhaul README for 4.0 release

* Comment synced_folders in .kitchen.yml

* Update list of dev-lxc commands in bash completion script

* Remove extra right side panes from cluster-view

* Remove WORKING_CONTAINER from PS1 prompt

* Remove xc-* bash functions

* Remove old unnecessary attributes

* Remove containers-view

* Remove version pin when installing dev-lxc gem

## 3.1.2 (2016-06-23)

* Pin to dev-lxc 1.7.0

* Add .gitattributes to force eol=lf handling

## 3.1.1 (2016-04-21)

* Use include_recipe in default.rb for all dev-lxc-platform recipes

* Enable synced_folders by default

## 3.1.0 (2016-04-19)

* Enable byobu by default for root user

* Use host's resolv.conf to resolve container FQDNs

## 3.0.0 (2016-04-14)

* Require Ubuntu 15.10 host VM to get LXD/LXC 2.0

* Uninstall system ruby

* Use lxc-copy instead of lxc-clone because lxc-clone is deprecated

* lxc-ls format column "memory" changed to "ram"

## 2.1.0 (2016-04-14)

* Add bash completion for common dev-lxc subcommands on container names

* Add bash completion for lxd-client

* No longer install parallel package

## 2.0.1 (2015-12-09)

* Install Sysdig in Ubuntu VM

## 2.0.0 (2015-12-08)

* Use Ubuntu 15.04 for host VM to allow creation of containers with systemd for init
  such as Ubuntu 15.04 and Centos 7

* Install LXD instead of just LXC

## 1.3.3 (2015-05-21)

* Delete SSH server host keys when images get cloned

## 1.3.2 (2015-05-18)

* Remove dependency on `realpath` in .envrc

## 1.3.1 (2015-05-14)

* Use more prescriptive synced_folders source

## 1.3.0 (2015-05-01)

* Update VAGRANT_CWD path for kitchen 1.4.0

## 1.2.0 (2015-05-01)

* Change the suggested mount point

## 1.1.0 (2015-04-21)

* Set PATH for xc-attach so it is exported in the attached environment.

* Add "containers-view" command
  * This creates a new tmux session with pre-arranged windows and panes
    that make it easier to see which containers are running.

## 1.0.0 (2015-04-09)
