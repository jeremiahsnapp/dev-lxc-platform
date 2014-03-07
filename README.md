## Description

The primary purpose of the dev-lxc-platform repo is to build a suitable environment for
the [dev-lxc](https://github.com/jeremiahsnapp/dev-lxc) tool which uses LXC containers
to build Chef server clusters.

The environment is also suitable for other tools that use LXC such as
[docker](https://www.docker.io/), [Test Kitchen](http://kitchen.ci/) and
[Chef Metal](http://www.getchef.com/blog/2014/03/04/chef-metal-0-2-release/)
or just general LXC container usage.

The dev-lxc-platform repo contains a Vagrantfile which uses an Ubuntu 13.10
[Vagrant base box](https://github.com/opscode/bento) created by Chef.

The Vagrantfile uses the dev-lxc-platform cookbook contained in this repo to install
and configure a suitable LXC with Btrfs backed container storage.

The Vagrantfile is configured to use 8GB ram in order to give plenty of room to run
multiple containers. Feel free to reduce this if it is too much for your environment.

The Vagrantfile is configured to mount `~/dev` directory from your workstation so you
can share things like Chef packages from your workstation to the Vagrant VM and
ultimately to running LXC containers. Feel free to change this to a directory that
is appropriate for your environment.

### Persistent Btrfs volume

Vagrant will create a second virtual disk to store the LXC containers in a Btrfs filesystem.
The vagrant-persistent-storage plugin will ensure the volume is detached before the VM is
destroyed and reattached when the VM is created.

While this persistent volume allows the Vagrant VM to treated as disposable I recommend
that you don't bother destroying the VM regularly unless you want to wait for it to be
provisioned each time.  I keep the VM running a lot of the time so I can jump in
and use it when I need to.  If I really want to shut it down I just `vagrant halt` it.

## Requirements

The Vagrantfile requires the Berkshelf gem and the following vagrant plugins.

    gem install berkshelf
    vagrant plugin install vagrant-berkshelf
    vagrant plugin install vagrant-omnibus
	vagrant plugin install vagrant-persistent-storage

### Workstation to Container Networking

Adding a route entry to the workstation enables direct communication between
the workstation and any container.

For OS X run the following command.
The route entry won't survive a worstation reboot. You will have to create it as needed.

    sudo route -n add 10.0.3.0/24 33.33.34.13

Your workstation needs to know how to resolve the .lxc domain.
For OS X you can run the following command.

    echo nameserver 10.0.3.1 | sudo tee /etc/resolver/lxc

### Start the vm and provision it.

    vagrant up

### Connect to the vm.

    vagrant ssh

### Use a terminal multiplexer

Since you may spend a lot of time doing work within the Vagrant vm you might
consider using a terminal multiplexer such as tmux or [byobu](http://byobu.co/).

These tools are already installed in the Vagrant vm.

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
