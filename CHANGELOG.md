# dev-lxc-platform Change Log

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
