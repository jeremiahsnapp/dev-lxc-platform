## dev-lxc-platform 5.0 Upgrade Instructions

If you want to continue using dev-lxc 1.x then use version 3.1.2 of the dev-lxc-platform cookbook.

dev-lxc-platform 5.0 is designed to use the new dev-lxc 2.x tool which has many breaking changes.
It is highly recommended that any existing version of dev-lxc-platform is destroyed first along
with its persistent storage disk.

1. Run `kitchen destroy` to destroy the host VM **BEFORE** pulling/downloading the new dev-lxc-platform code.
   Destroying the VM before downloading the new dev-lxc-platform code avoids complications caused by the new
   `.kitchen.yml` file pointing to the Ubuntu image.

2. Make sure you have the latest version of Vagrant and Virtualbox installed. This has been tested with Vagrant 1.8.5 and Virtualbox 5.0.14.

3. Upgrade the `vagrant-persistent-storage` plugin.
   `vagrant plugin update vagrant-persistent-storage`

4. WARNING - this step will destroy existing containers. This step is only required if you are upgrading from dev-lxc 1.x to 2.x style clusters.
   `rm ~/VirtualBox VMs/dev-lxc-platform.vdi`

5. Run `git pull --rebase` if you already have a clone of the dev-lxc-platform repository or download the
   latest dev-lxc-platform cookbook code.

6. Delete the `Berksfile.lock` file if it exists so new versions of required cookbooks will be used.

7. Run `kitchen converge` from the root directory of the dev-lxc-platform cookbook to build the new
   Ubuntu host VM.

8. Login to the new VM and start using the dev-lxc 2.x tool.

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

Creating snapshot clones of Btrfs backed containers is very fast which is helpful
especially for experimenting and troubleshooting.

## Requirements

Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads).

Download and install [Vagrant](https://www.vagrantup.com/downloads.html).

Install the vagrant-persistent-storage plugin.

```
vagrant plugin install vagrant-persistent-storage
```

Download and install [ChefDK](http://downloads.chef.io/).

Run `chef shell-init` to read its usage docs. Then run the appropriate command for your shell.

### Workstation to Container Networking

Adding a route entry to the workstation enables direct communication between
the workstation and any container.

For OS X run the following command.
The route entry won't survive a worstation reboot. You will have to create it as needed.

    sudo route -n add 10.0.3.0/24 33.33.34.13

Your workstation needs to know how to resolve the .lxc domain.
For OS X you can run the following command.

    echo nameserver 10.0.3.1 | sudo tee /etc/resolver/lxc

### Kitchen Configuration

The dev-lxc-platform repo contains a .kitchen.yml which uses an Ubuntu 16.10
[Vagrant base box](https://github.com/opscode/bento) created by Chef.

The .kitchen.yml is configured to install ChefDK into the Vagrant VM for provisioning.
The root user's shell environment is also configured to use ChefDK as the default ruby.
This makes dev-lxc-platform a great platform for testing and experimenting with other
Chef container technologies.

The .kitchen.yml uses the dev-lxc-platform cookbook contained in this repo to install
and configure a suitable LXC with Btrfs backed container storage.

The .kitchen.yml is configured to use 6GB ram in order to give plenty of room to run
multiple containers. Feel free to reduce this if it is too much for your environment.

The .kitchen.yml has a commented out `synced_folders` section.
Uncomment and configure the section appropriately if you want to mount a directory from
your workstation into the Vagrant VM. This is useful for sharing things from your workstation
into the Vagrant VM and ultimately into running LXC containers.

### Persistent Btrfs volume

Vagrant will create a second virtual disk to store the LXC containers in a Btrfs filesystem.
The vagrant-persistent-storage plugin will ensure the volume is detached before the VM is
destroyed and reattached when the VM is created.

While this persistent volume allows the Vagrant VM to be treated as disposable I recommend
that you don't bother destroying the VM regularly unless you want to wait for it to be
provisioned each time.  I keep the VM running a lot of the time so I can jump in
and use it when I need to.  If I really want to shut it down I just `vagrant halt` it.

### Enable standard Vagrant commands

Since the dev-lxc-platform VM is created using test-kitchen normal Vagrant commands will not
affect the VM.

Enabling standard Vagrant can be useful especially since test-kitchen is not able to halt the VM.

Correctly setting the `VAGRANT_CWD` environment variable will allow Vagrant commands to be used.

You can run the following command in the top level directory of the `dev-lxc-platform` repo.

```
export VAGRANT_CWD="$(pwd)/.kitchen/kitchen-vagrant/kitchen-dev-lxc-platform-default-ubuntu-1510"
```

Alternatively, you can use [direnv](http://direnv.net/) with the `.envrc` file included in the
dev-lxc-platform repo to automatically set `VAGRANT_CWD` upon entering the top level directory
of the dev-lxc-platform repo.

If you have `homebrew` installed in OS X then you can install `direnv` by running `brew install direnv`.

Be sure to follow the [direnv install instructions](http://direnv.net/) to add the appropriate line
to your user's <shell>rc file.

## LXC Introduction

Read the following introduction to LXC if you aren't already familiar with it.

[LXC Introduction](https://linuxcontainers.org/lxc/introduction/)

[LXC Articles](https://linuxcontainers.org/lxc/articles/)

[LXC Getting Started](https://linuxcontainers.org/lxc/getting-started/)

## LXD Introduction

[LXD Introduction](https://linuxcontainers.org/lxd/introduction/)

[LXD Getting Started](https://linuxcontainers.org/lxd/getting-started-cli/)

[LXD Articles](https://linuxcontainers.org/lxd/articles/)

## Usage

### Create the vm and converge it.

    kitchen converge

### Connect to the vm.

    kitchen login

### Switch to the root user

```
sudo -i
```

Once you switch to the root user you will be in a [byobu](http://byobu.co/) terminal session.

Byobu is a GPLv3 open source text-based window manager and terminal multiplexer which is very helpful
when working with dev-lxc.

The prefix key is set to `Ctrl-o`

Pressing `Fn-F1` in OS X will get you a help screen and selecting the "Quick Start Guide"
will give you a list of frequently used key bindings.

### Use dev-lxc

Read the [dev-lxc README](https://github.com/jeremiahsnapp/dev-lxc)
