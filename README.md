
## Description

This repo contains a Vagrantfile designed to use the Opscode Ubuntu 13.10
provisionerless Vagrant base box and use the self-contained dev-lxc cookbook
to install Btrfs and LXC and configure it in a useful way.

The Vagrantfile is configured to mount a `../downloads` directory from your
workstation.  Put your software packages in the `../downloads` directory on
your workstation so you don't have to download them to the vm.

### Persistent Btrfs volume

Vagrant will create a second disk to store the LXC containers in a Btrfs
filesystem.  The vagrant-persistent-storage plugin will ensure the volume
is detached before the vm is destroyed and reattached when the vm is created.

## Here are some good LXC  docs

### LXC

1. https://help.ubuntu.com/lts/serverguide/lxc.html
2. http://containerops.org/2013/11/19/lxc-networking/

## Requirements

The Vagrantfile requires the Berkshelf gem and the following vagrant plugins.

    gem install berkshelf
    vagrant plugin install vagrant-berkshelf
    vagrant plugin install vagrant-omnibus
	vagrant plugin install vagrant-persistent-storage

### Start the vm and provision it.

    vagrant up

### Connect to the vm.

    vagrant ssh

### Use a terminal multiplexer

Since you may spend a lot of time doing work within the Vagrant vm you might
consider using a terminal multiplexer such as tmux or byobu (enhanced tmux).

These tools are already installed in the Vagrant vm by the
dev-lxc::helpful-packages recipe.

## Containers

### Create containers using Btrfs backingstore.

Container creation can take awhile the first time but subsequent creation of
similar containers is faster because it uses a cache stored in `/var/cache/lxc`.

Using the Btrfs backing store makes the container's rootfs a Btrfs subvolume.
This ensures that snapshot clones of the container or `lxc-snapshot`'s of the
container are thinly provisioned which conserves disk space.

The containers are created in `/var/lib/lxc`.

I prepended the names of each container with `g-` to identify these as "golden"
containers.  Normally I will clone these containers rather than run them.

    sudo lxc-create -B btrfs -t ubuntu -n g-ubuntu-lucid -- -r lucid
    sudo lxc-create -B btrfs -t ubuntu -n g-ubuntu-precise -- -r precise
    sudo lxc-create -B btrfs -t centos -n g-centos-5 -- -R 5
    sudo lxc-create -B btrfs -t centos -n g-centos-6 -- -R 6

Ubuntu templates use 'ubuntu' for the default username and password.

Centos templates use 'root' for the default username and password.

### Install useful tools in the golden containers.

    chroot /var/lib/lxc/g-ubuntu-lucid/rootfs/ apt-get install -y man curl wget vim-nox emacs22-nox
    chroot /var/lib/lxc/g-ubuntu-precise/rootfs/ apt-get install -y man curl wget vim-nox emacs23-nox
    chroot /var/lib/lxc/g-centos-5/rootfs/ yum install -y which man curl wget vim-enhanced emacs-nox
    chroot /var/lib/lxc/g-centos-6/rootfs/ yum install -y which man curl wget vim-enhanced emacs-nox

### Install latest Chef client in the golden containers.

    curl -L https://www.opscode.com/chef/install.sh | chroot /var/lib/lxc/g-ubuntu-lucid/rootfs/ bash
    curl -L https://www.opscode.com/chef/install.sh | chroot /var/lib/lxc/g-ubuntu-precise/rootfs/ bash
    curl -L https://www.opscode.com/chef/install.sh | chroot /var/lib/lxc/g-centos-5/rootfs/ bash
    curl -L https://www.opscode.com/chef/install.sh | chroot /var/lib/lxc/g-centos-6/rootfs/ bash

### Optional - Install a specific version of Chef client.

    curl -L https://www.opscode.com/chef/install.sh | chroot /var/lib/lxc/g-ubuntu-precise/rootfs/ bash -s -- -v 11.8.2
	
### Clone a container.

Using the `-s` snapshot option will automatically use Btrfs to conserve disk space.

    sudo lxc-clone -s -o g-ubuntu-precise -n ubuntu-precise

A Clone's `/etc/hostname` gets auto-updated but `/etc/hosts` does not so
`/etc/hosts` needs to be updated with the new hostname.

    sudo chroot /var/lib/lxc/ubuntu-precise/rootfs sed -i "/127.0.1.1/ c\127.0.1.1   ubuntu-precise" /etc/hosts

### Configure a container to mount the Vagrant vm's `/downloads` directory.

    sudo chroot /var/lib/lxc/ubuntu-precise/rootfs mkdir /downloads
    sudo sed -i '$ a\lxc.mount.entry = /downloads /var/lib/lxc/ubuntu-precise/rootfs/downloads none bind 0 0' /var/lib/lxc/ubuntu-precise/config

### Start the container.

    sudo lxc-start -d -n ubuntu-precise

### Connect to the container.

    sudo lxc-console -n ubuntu-precise

### Detach from the container.

    CTRL-a q

### List containers.

This will also show you a running container's IP address.

    sudo lxc-ls --fancy

### Stop the container.

    sudo lxc-stop -n ubuntu-precise

### Destroy the container.

    sudo lxc-destroy -n ubuntu-precise

## Workstation to Container Networking

### Recommended: Affects all containers.

Adding a route entry to the workstation enables direct communication between
the workstation and any container.

For OS X run the following command. This route entry won't survive a worstation reboot.

sudo route -n add 10.0.3.0/24 33.33.34.13

### Alternative: Affects inidividual container.

#### Vagrant VM's iptables

If adding a route entry in the workstation as described above is not desirable then
you may choose to use the Vagrant vm's iptables.
The Vagrant vm's iptables offers a flexible way to alter network paths between the
workstation and containers.

#### View the Vagrant vm's iptables NAT settings.

    sudo iptables -t nat -nL PREROUTING

#### Configure iptables for an individual container.

If a container's IP is 10.0.3.238 it can be reached directly from the
workstation by adding appropriate NAT rules to iptables.

Here are a couple of examples for adding and removing these rules.

    # All traffic sent from workstation to 33.33.34.13 will get forwarded to the container.
    sudo iptables -t nat -A PREROUTING -d 33.33.34.13 -j DNAT --to-destination 10.0.3.238

    # Delete the rule when it is not needed.
    sudo iptables -t nat -D PREROUTING -d 33.33.34.13 -j DNAT --to-destination 10.0.3.238

    # Traffic sent from workstation to 33.33.34.13:22 will get forwarded to the container's port 22.
    sudo iptables -t nat -A PREROUTING -d 33.33.34.13 -p tcp --dport 22 -j DNAT --to-destination 10.0.3.238:22

    # Delete the rule when it is not needed.
    sudo iptables -t nat -D PREROUTING -d 33.33.34.13 -p tcp --dport 22 -j DNAT --to-destination 10.0.3.238:22

#### Additional setup for iptables and multiple containers.

Add additional IP addresses to the Vagrant vm's eth1 interface and then add
iptables NAT rules appropriately.

    sudo ip addr add 33.33.34.14/32 dev eth1
    sudo ip addr delete 33.33.34.14/32 dev eth1
