## Description

The primary purpose of the dev-lxc-platform repo is to build a suitable environment for
the [dev-lxc](https://github.com/jeremiahsnapp/dev-lxc) tool which uses LXC containers
to build Chef server clusters.

The environment is also suitable for other tools that use LXC such as
[LXD](https://linuxcontainers.org/lxd/introduction/), [docker](https://www.docker.io/),
[Test Kitchen](http://kitchen.ci/) and
[Chef Provisioning](https://docs.chef.io/provisioning.html)
or just general LXC container usage.

### Features

1. LXD and LXC Containers - Resource efficient servers with fast start/stop times and standard init
2. Btrfs - Efficient, persistent storage backend provides fast, lightweight container cloning
3. Dnsmasq - DHCP networking and DNS resolution
4. Base Containers - Containers that are built to resemble a traditional server
5. Sysdig preinstalled for awesome transparency into container activity
6. mitmproxy preinstalled for awesome transparency into HTTP(S) requests

Creating snapshot clones of Btrfs backed containers is very fast which is helpful
especially for experimenting and troubleshooting.

## Build dev-lxc-platform instance

The dev-lxc tool is used in a system that has been configured by the dev-lxc-platform cookbook.

The easiest way to build a dev-lxc-platform system is to download the dev-lxc-platform repository
and use Test Kitchen to build a VirtualBox Vagrant instance or an AWS EC2 instance.

Install the [Chef DK](http://downloads.chef.io/) which provides Test Kitchen and other required tools.

Run `chef shell-init` to display its usage docs. Then run the appropriate command for your shell.

Vagrant instance prerequisites:

* Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* Install [Vagrant](https://www.vagrantup.com/downloads.html)
* Install the `vagrant-persistent-storage` plugin by running the following command.

```
vagrant plugin install vagrant-persistent-storage
```

The `vagrant-persistent-storage` plugin will create a second virtual disk to store the LXC containers in a Btrfs filesystem.
It will also ensure the volume is detached before the instance is destroyed and reattached when the instance is created.
This means you could run `kitchen destroy vagrant && kitchen converge vagrant` and you would still be able to use containers
that you created prior to rebuilding the Vagrant instance. However, to avoid rebuilding the Vagrant instance unnecessarily
you could use the `kitchen-instance-ctl` command to stop and start the instance as described below.

EC2 instance prerequisites:

* Make sure your `~/.aws/config` or `C:\Users\USERNAME \.aws\config` file's contents look similar to the following.

```
[default]
aws_access_key_id=<your aws access key id>
aws_secret_access_key=<your aws secret access key>
region=<your preferred aws region>
```

Download the dev-lxc-platform repository to your workstation.

```
git clone https://github.com/jeremiahsnapp/dev-lxc-platform.git
cd dev-lxc-platform
```

Configure .kitchen.yml for the instance you are building.

* EC2: (required) Set `aws_ssh_key_id` and `transport ssh_key`
* Vagrant: (optional) Set `cpus`, `memory`, `synced_folders` and `persistent_storage location`

Build the instance.

```
kitchen converge <ec2 or vagrant>
```

## Stop and start dev-lxc-platform instances

It can be helpful to stop an instance and start it up again when it's needed but Test Kitchen does not provide a way to do this.

The `kitchen-instance-ctl` command in the root of the dev-lxc-platform repository provides the ability to stop, start and get the status of the kitchen instances.

```
cd dev-lxc-platform
./kitchen-instance-ctl status <ec2 or vagrant>
./kitchen-instance-ctl stop <ec2 or vagrant>
./kitchen-instance-ctl start <ec2 or vagrant>
```

## Upgrade dev-lxc-platform instances

```
cd dev-lxc-platform
kitchen destroy
git stash
git pull --rebase
rm Berksfile.lock
# reapply necessary changes to .kitchen.yml
kitchen converge <ec2 or vagrant>
```

## Web browser access

Web browser access to containers created inside a dev-lxc-plaform instance requires an SSH connection to the dev-lxc-plaform instance with SOCKS v5 dynamic forwarding enabled.

Append the following contents to your workstation's SSH config file so the `kitchen login` command will automatically create an
SSH connection with SOCKS v5 dynamic forward enabled. Then configure the web browser to use SOCKS v5 proxy "127.0.0.1 1080" and "Proxy DNS when using SOCKS5 proxy". Be aware that logging out of the SSH session will appear to hang as long as the web browser session is still running.

```
# for dev-lxc-platform EC2 instance
Host *.amazonaws.com
  DynamicForward 1080

# for dev-lxc-platform Vagrant instance
Host 127.0.0.1
  DynamicForward 1080
EOF
```

## Login to the dev-lxc-platform instance

Login to the dev-lxc-platform instance and switch to the root user.

```
kitchen login <ec2 or vagrant>
sudo -i
```

When you are logged in as the root user you should automatically enter a [byobu session](http://byobu.co/).

Byobu makes it easy to manage multiple terminal windows and panes. You can press `F1` to get help which includes a [list of keybindings](http://manpages.ubuntu.com/manpages/wily/en/man1/byobu.1.html#contenttoc8).

The prefix key is set to `Ctrl-o`

Some of the keys that will be most useful to you are:

* `option-Up`, `option-Down` to switch between Byobu sessions
* `option-Left`, `option-Right` to switch between windows in a session
* `shift-Left`, `shift-Right`, `shift-Up`, `shift-Down` to switch between panes in a window

### Use dev-lxc

Read the [dev-lxc README](https://github.com/jeremiahsnapp/dev-lxc)

## LXC Introduction

[LXC Blog Series - by LXC Project Lead Stéphane Graber](https://www.stgraber.org/2013/12/20/lxc-1-0-blog-post-series/)

[LXC Introduction](https://linuxcontainers.org/lxc/introduction/)

[LXC Articles](https://linuxcontainers.org/lxc/articles/)

[LXC Getting Started](https://linuxcontainers.org/lxc/getting-started/)

## LXD Introduction

[LXD Blog Series - by LXD Project Lead Stéphane Graber](https://www.stgraber.org/2016/03/11/lxd-2-0-blog-post-series-012/)

[LXD Introduction](https://linuxcontainers.org/lxd/introduction/)

[LXD Getting Started](https://linuxcontainers.org/lxd/getting-started-cli/)

[LXD Articles](https://linuxcontainers.org/lxd/articles/)
