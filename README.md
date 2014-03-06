## Description

The dev-lxc-platform repo contains a Vagrantfile designed to use the Opscode Ubuntu 13.10
provisionerless Vagrant base box and use the self-contained dev-lxc-platform cookbook
to install Btrfs and LXC and configure them to build a suitable environment for the
use of the [dev-lxc tool](https://github.com/jeremiahsnapp/dev-lxc).

The dev-lxc tool uses LXC containers to build Chef server clusters.

The contained Vagrantfile is configured to use 8GB ram in order to give plenty of room to run
multiple containers. Feel free to reduce this if it is too much for your environment.

The contained Vagrantfile is configured to mount `~/dev` directory from your workstation.
You can put Chef packages somewhere under the `~/dev` directory on your workstation so
you don't have to download them to the vm.

### Persistent Btrfs volume

Vagrant will create a second virtual disk to store the LXC containers in a Btrfs filesystem.
The vagrant-persistent-storage plugin will ensure the volume is detached before the vm is
destroyed and reattached when the vm is created.

While this persistent volume allows the Vagrant VM to treated as disposable I recommend
that you don't bother destroying it regularly unless you want to wait for it to be
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

The prefix key is set to `Ctrl-o`

## LXC Introduction

Read the following introduction to LXC if you aren't already familiar with it.

[LXC 1.0 Introduction](https://www.stgraber.org/2013/12/20/lxc-1-0-blog-post-series/)

## Basic LXC Usage

The following commands must be run as the root user.

### Create the container.

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

### Destroy the container.

    lxc-destroy -n ubuntu-1204
