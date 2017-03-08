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
6. tinyproxy preinstalled for easy web access to containers
7. mitmproxy preinstalled for awesome transparency into HTTP(S) requests
8. Docker preinstalled
9. chef-load preinstalled

Creating snapshot clones of Btrfs backed containers is very fast which is helpful
especially for experimenting and troubleshooting.

## Build dev-lxc-platform instance

The dev-lxc tool is used in a system that has been configured by the dev-lxc-platform cookbook.

The easiest way to build a dev-lxc-platform system is to download the dev-lxc-platform repository
and use Test Kitchen to build an AWS EC2 instance or a VirtualBox Vagrant instance.

#### Install Chef DK

Install the [Chef DK](http://downloads.chef.io/) which provides Test Kitchen and other required tools.

Run `chef shell-init` to display its usage docs. Then run the appropriate command for your shell.

#### EC2 instance prerequisites:

* Make sure you have an [SSH key pair setup](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair) for your AWS EC2 region.
* Make sure your `~/.aws/credentials` or `C:\Users\USERNAME\.aws\credentials` file's contents look similar to the following.

```
[default]
aws_access_key_id=<your aws access key id>
aws_secret_access_key=<your aws secret access key>
region=<your preferred aws region>
```

#### Vagrant instance prerequisites:

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

#### Download dev-lxc-platform

Download the dev-lxc-platform repository to your workstation.

```
git clone https://github.com/jeremiahsnapp/dev-lxc-platform.git
cd dev-lxc-platform
```

#### Configure .kitchen.yml

Configure .kitchen.yml for the instance you are building.

* EC2:
  * (required) Set `region`, `aws_ssh_key_id` and `transport ssh_key`
  * (optional) Set `tags`
* Vagrant:
  * (required) Uncomment the vagrant platform configuration
  * (optional) Set `cpus`, `memory`, `synced_folders` and `persistent_storage location`

#### Build the instance.

```
kitchen converge <ec2 or vagrant>
```

## Accessing the containers using a web proxy

Systems that are external to the dev-lxc-platform, such as your workstation, must use a web proxy to access the containers running inside the dev-lxc-platform instance.

The dev-lxc-platform runs an instance of tinyproxy on port 8888 to make it easy to access the containers' web ports.

The dev-lxc-platform also has mitmproxy installed which is a fantastic web proxy console tool which you can choose to send web traffic through to troubleshoot a problem or just simply explore the traffic. You must start mitmproxy when you want to use it. When it's running it listens on port 8080.

If you are running your dev-lxc-platform instance in EC2 you might not have direct network access to dev-lxc-platform's port 8888 or port 8080. In that case, you can append the following contents to your system's SSH config file, `~/.ssh/config` or `C:\Users\USERNAME\.ssh\config`, so the `kitchen login` command will automatically forward your system's port 8888 and port 8080 to port 8888 and port 8080 in the dev-lxc-platform instance.

```
# for dev-lxc-platform Vagrant and EC2 instances
Host 127.0.0.1 *.amazonaws.com
  # LocalForward for proxying web traffic to tinyproxy running in the dev-lxc-platform instance
  LocalForward 127.0.0.1:8888 127.0.0.1:8888
  # LocalForward for proxying web traffic to mitmproxy running in the dev-lxc-platform instance
  LocalForward 127.0.0.1:8080 127.0.0.1:8080
```

Then you can configure your system's web browser or command line tools to use either of the following for HTTP and HTTPS proxies so they can access dev-lxc containers' web ports.

tinyproxy: `127.0.0.1:8888`

mitmproxy: `127.0.0.1:8080`

Be aware that logging out of the SSH session will appear to hang as long as the web browser or command line tool has a proxied session running.

## Login to the dev-lxc-platform instance

Login to the dev-lxc-platform instance and switch to the root user.

```
kitchen login <ec2 or vagrant>
sudo -i
```

When you are logged in as the root user you should automatically enter a [byobu session](http://byobu.co/).

### Byobu keybindings

Byobu makes it easy to manage multiple terminal windows and panes. You can press `F1` to get help which includes a [list of keybindings](http://manpages.ubuntu.com/manpages/wily/en/man1/byobu.1.html#contenttoc8).

`C-` refers to the keyboard's `Control` key.
`M-` refers to the keyboard's `Meta` key which is the `Alt` key on a PC keyboard and the `Option` key on an Apple keyboard.

The prefix key is set to `C-o`

Some of the keyboard shortcuts that will be most useful to you are:

* `M-Up`, `M-Down` - switch between Byobu sessions
* `M-Left`, `M-Right` - switch between windows in a session
* `shift-Left`, `shift-Right`, `shift-Up`, `shift-Down` - switch between panes in a window
  * Windows users using Conemu must first disable "Start selection with Shift+Arrow" in "Mark/Copy" under the "Keys & Macro" settings
* `C-o C-s` - synchronize panes
* `C-o z` - zoom into and out of a pane
* `C-o M-1` - evenly split panes horizontally
* `C-o M-2` - evenly split panes vertically
* `M-pageup`, `M-pagedown` - page up/down in scrollback

Note: `Shift-F2` does not create horizontal splits for Windows users. Use the `C-o |` key binding instead.

## Use dev-lxc

Read the [dev-lxc README](https://github.com/jeremiahsnapp/dev-lxc)

## Transferring files to EC2 instance

The .kitchen.yml EC2 config uses cloud-config user-data to enable root user SSH access using the same key pair used when logging in as the ubuntu user.

This makes it easy to use tools such as rsync or Filezilla to transfer files from your workstation directly to the root user's home directory.

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

If you are upgrading to a new major version then you should destroy the instances first otherwise proceed to the next steps.

```
cd dev-lxc-platform
kitchen destroy
rm Berksfile.lock
```

Pull down the latest dev-lxc-platform code and converge the instances.

```
git stash
git pull --rebase
# reapply necessary changes to .kitchen.yml using `git stash pop` or manually if necessary
kitchen converge <ec2 or vagrant>
```

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
