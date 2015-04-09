## Description

The primary purpose of the dev-lxc-platform repo is to build a suitable environment for
the [dev-lxc](https://github.com/jeremiahsnapp/dev-lxc) tool which uses LXC containers
to build Chef server clusters.

The environment is also suitable for other tools that use LXC such as
[docker](https://www.docker.io/), [Test Kitchen](http://kitchen.ci/) and
[Chef Provisioning](https://docs.chef.io/provisioning.html)
or just general LXC container usage.

### Features

1. LXC 1.0 Containers - Resource efficient servers with fast start/stop times and standard init
2. Btrfs - Efficient, persistent storage backend provides fast, lightweight container cloning
3. Dnsmasq - DHCP networking and DNS resolution
4. Platform Images - Images that are built to resemble a traditional server

Creating snapshot clones of Btrfs backed containers is very fast which is helpful
especially for experimenting and troubleshooting.

## Requirements

Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads).

Download and install [Vagrant](https://www.vagrantup.com/downloads.html).

Install the vagrant-persistent-storage plugin.

```
vagrant plugin install vagrant-persistent-storage
```

Download and install [ChefDK](http://downloads.chef.io/chef-dk/).

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

The dev-lxc-platform repo contains a .kitchen.yml which uses an Ubuntu 14.04
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
your workstation into the Vagrant VM. This is useful for sharing things like Chef packages
from your workstation into the Vagrant VM and ultimately into running LXC containers.

### Create the vm and converge it.

    kitchen converge

### Persistent Btrfs volume

Vagrant will create a second virtual disk to store the LXC containers in a Btrfs filesystem.
The vagrant-persistent-storage plugin will ensure the volume is detached before the VM is
destroyed and reattached when the VM is created.

While this persistent volume allows the Vagrant VM to be treated as disposable I recommend
that you don't bother destroying the VM regularly unless you want to wait for it to be
provisioned each time.  I keep the VM running a lot of the time so I can jump in
and use it when I need to.  If I really want to shut it down I just `vagrant halt` it.

### Connect to the vm.

    kitchen login

### Enable standard Vagrant commands

Since the dev-lxc-platform VM is created using test-kitchen normal Vagrant commands will not
affect the VM.

Enabling standard Vagrant can be useful especially since test-kitchen is not able to halt the VM.

Correctly setting the `VAGRANT_CWD` environment variable will allow Vagrant commands to be used.

You can run the following command in the top level directory of the `dev-lxc-platform` repo.

```
export VAGRANT_CWD=$(realpath .kitchen/kitchen-vagrant/default-ubuntu-1310)
```

Alternatively, you can use [direnv](http://direnv.net/) with the `.envrc` file included in the
dev-lxc-platform repo to automatically set `VAGRANT_CWD` upon entering the top level directory
of the dev-lxc-platform repo.

If you have `homebrew` installed in OS X then you can install `direnv` by running `brew install direnv`.

### Use a terminal multiplexer

Since you may spend a lot of time doing work within the Vagrant VM you should
consider using a terminal multiplexer such as tmux or [byobu](http://byobu.co/).

These tools are already installed in the Vagrant VM.

Once you login to the root user you can set byobu to auto-run on every login by
running the following command.

    byobu-enable

You can easily disable auto-run at any time using `byobu-disable`.

The prefix key is set to `Ctrl-o`

Pressing `Fn-F1` in OS X will get you a help screen and selecting the "Quick Start Guide"
will give you a list of frequently used key bindings.

## LXC Introduction

Read the following introduction to LXC if you aren't already familiar with it.

[LXC 1.0 Introduction](https://www.stgraber.org/2013/12/20/lxc-1-0-blog-post-series/)

## Usage

### Use root

The following commands must be run as the root user so once you login to the Vagrant VM you
should run `sudo -i` to login as the root user.

### Create a Platform Image

Use the installed dev-lxc tool to create a platform image. These platform images can then
be cloned into new containers.

You can see a menu of platform images this tool can create by using the following command.

```
dev-lxc create
```

The initial creation of platform images can take a few minutes so let's start creating
an Ubuntu 14.04 image now.

```
dev-lxc create p-ubuntu-1404
```

### Base Container / Working Container Workflow

The dev-lxc-platform has a number of bash functions with names that begin with `xc-`.
Many of these are simple wrappers around their counterpart `lxc-` command.
Type `xc-` and hit the TAB key a couple times to see the list of commands.

The `xc-` commands are designed to use environment variables to identify what container to
act on. This makes the commands easier to run compared to the `lxc-` commands requirements.

The `BASE_CONTAINER` environment variable can be set to the name of the container that
should be used during cloning operations.

If the name of the base container is specified when running an `xc-` command then the
`BASE_CONTAINER` variable is set to that name. Then subsequent `xc-` commands can be
run without specifying the name and the same container will continue to be treated as the
base container.

The `WORKING_CONTAINER` environment variable can be set to the name of the container that
should be acted on by the `xc-` command.

If the name of the working container is specified when running an `xc-` command then the
`WORKING_CONTAINER` variable is set to that name. Then subsequent `xc-` commands can be
run without specifying the name and the same container will continue to be treated as the
working container.

For example:

Clone base container named "p-ubuntu-1404" into working container named "test.lxc" and start it.

```
xc-start p-ubuntu-1404 test.lxc
```

Show (or manually set) the name of the base container and working container.

```
xc-base
xc-working
```

Destroy "test.lxc".

```
xc-destroy
```

Re-clone base container named "p-ubuntu-1404" into working container named "test.lxc" and start it.

```
xc-start
```

#### Mount directories into the working container

Mount the Vagrant VM's `/dev-shared` directory into the working container.

```
xc-mount /dev-shared dev-shared
xc-stop
xc-start
```

#### Run a command in the working container without logging into it

```
xc-attach uptime
```

#### Attach the terminal to the working container

```
xc-attach
```

#### Use dev-lxc to install Chef Client into a container.

```
dev-lxc install-chef-client $(xc-working)
```

dev-lxc can also configure Chef Client in a container and/or bootstrap it.
Read the help docs for the following commands.

```
dev-lxc help configure-chef-client
dev-lxc help bootstrap-container
```

## Basic LXC Usage

### Use root

The following commands must be run as the root user so once you login to the Vagrant VM you
should run `sudo -i` to login as the root user.

### Create a container.

Using the 'download' template is a very fast and storage efficient way to create a container
for many distros since it actually downloads the compressed tarball of a prebuilt container's rootfs.

By default the download template pulls from https://images.linuxcontainers.org/ but you can
also use template parameters to specify a different image site.

As an alternative to the 'download' template you could use any other template that is found in
`/usr/share/lxc/templates/` or create your own.

    lxc-create -B btrfs -t download -n ubuntu-1204 -- -d ubuntu -r precise -a amd64

### Start the container.

    lxc-start -d -n ubuntu-1204

### Connect to the container's console.

    lxc-console -n ubuntu-1204

### Detach from the container.

    CTRL-a q

### Attach to the container as the root user without having to login.

    lxc-attach -n ubuntu-1204

### List containers.

    lxc-ls --fancy

### Stop the container.

    lxc-stop -n ubuntu-1204

### Clone the container.

    lxc-clone -s -o ubuntu-1204 -n ubuntu-1204-2

### Destroy the container.

    lxc-destroy -n ubuntu-1204
