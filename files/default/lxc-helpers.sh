# List all containers
alias xcl='lxc-ls --fancy'

# Set default value of GOLDEN_CONTAINER
export GOLDEN_CONTAINER=g-ubuntu-precise-chef-client

# Set and show GOLDEN_CONTAINER
function xcg {
    [[ -n $1 ]] && GOLDEN_CONTAINER=$1
    echo "GOLDEN_CONTAINER is set to '$GOLDEN_CONTAINER'"
}
# Set and show WORKING_CONTAINER
function xcw {
    [[ -n $1 ]] && WORKING_CONTAINER=$1
    echo "WORKING_CONTAINER is set to '$WORKING_CONTAINER'"
}
# Run command in WORKING_CONTAINER
# If no arguments are given then log into WORKING_CONTAINER
function xca {
    if (( ! $# )); then
	echo "Logging into '$WORKING_CONTAINER' as user '$USER'"
    else
	echo "Running command in '$WORKING_CONTAINER'"
    fi
    lxc-attach -n $WORKING_CONTAINER --clear-env -- $@
}
# Run command in WORKING_CONTAINER chroot
function xc-chroot {
    echo "Running command in '$WORKING_CONTAINER' chroot"
    chroot "/var/lib/lxc/$WORKING_CONTAINER/rootfs" $@
}
# xci chef_version
#   Install specific version of Chef in WORKING_CONTAINER
#
# xci
#   Install latest version of  Chef in WORKING_CONTAINER
function xci {
    if [[ -n $1 ]]; then
	local CHEF_VERSION="-v $1"
    fi
    echo "Installing Chef $1 on '$WORKING_CONTAINER'"
    curl -L https://www.opscode.com/chef/install.sh | chroot /var/lib/lxc/$WORKING_CONTAINER/rootfs/ bash -s -- $CHEF_VERSION
}
# xcz container
#   Set WORKING_CONTAINER to container
#   Configure WORKING_CONTAINER to work with chef-zero
#
# xcz
#   Configure WORKING_CONTAINER to work with chef-zero
function xcz {
    if [[ -n $1 ]]; then
	echo "Setting WORKING_CONTAINER=$1"
	WORKING_CONTAINER=$1
    fi
    echo "Configuring Chef's client.rb in '$WORKING_CONTAINER' to work with chef-zero"
    if chroot /var/lib/lxc/$WORKING_CONTAINER/rootfs [ ! -a /root/chef-zero.pem ]; then
	chroot /var/lib/lxc/$WORKING_CONTAINER/rootfs ssh-keygen -t rsa -f /root/chef-zero.pem
    fi
    if chroot /var/lib/lxc/$WORKING_CONTAINER/rootfs [ ! -d /etc/chef ]; then
	chroot /var/lib/lxc/$WORKING_CONTAINER/rootfs mkdir /etc/chef
    fi
    echo "chef_server_url 'http://33.33.34.1:8889'" | chroot /var/lib/lxc/$WORKING_CONTAINER/rootfs tee /etc/chef/client.rb
    echo "client_key '/root/chef-zero.pem'" | chroot /var/lib/lxc/$WORKING_CONTAINER/rootfs tee -a /etc/chef/client.rb
}
# xcs container1 container2
#   Set GOLDEN_CONTAINER to container1 and WORKING_CONTAINER to container2
#   If WORKING_CONTAINER does not exist then clone GOLDEN_CONTAINER to WORKING_CONTAINER
#   Start WORKING_CONTAINER
#
# xcs container
#   Set WORKING_CONTAINER to container
#   If WORKING_CONTAINER does not exist then clone GOLDEN_CONTAINER to WORKING_CONTAINER
#   Start WORKING_CONTAINER
#
# xcs
#   If WORKING_CONTAINER does not exist then clone GOLDEN_CONTAINER to WORKING_CONTAINER
#   Start WORKING_CONTAINER
function xcs {
    if [[ -n $1 ]]; then
	if [[ -n $2 ]]; then
	    echo "Setting GOLDEN_CONTAINER=$1"
	    GOLDEN_CONTAINER=$1
	    echo "Setting WORKING_CONTAINER=$2"
	    WORKING_CONTAINER=$2
	else
	    echo "Setting WORKING_CONTAINER=$1"
	    WORKING_CONTAINER=$1
	fi
    fi
    if ! lxc-info -n $WORKING_CONTAINER &> /dev/null; then
	echo "Cloning '$GOLDEN_CONTAINER' into '$WORKING_CONTAINER'"
	lxc-clone -s -o $GOLDEN_CONTAINER -n $WORKING_CONTAINER
    fi
    echo "Starting '$WORKING_CONTAINER'"
    lxc-start -d -n $WORKING_CONTAINER
    echo "Waiting for '$WORKING_CONTAINER' to be RUNNING"
    lxc-wait -t 10 -n $WORKING_CONTAINER -s RUNNING
}
# xck container
#   Set WORKING_CONTAINER to container
#   Stop WORKING_CONTAINER
#
# xck
#   Stop WORKING_CONTAINER
function xck {
    if [[ -n $1 ]]; then
	echo "Setting WORKING_CONTAINER=$1"
	WORKING_CONTAINER=$1
    fi
    echo "Stopping '$WORKING_CONTAINER'"
    lxc-stop -n $WORKING_CONTAINER
}
# Stop all containers
function xcka {
    for CONTAINER in $(lxc-ls -1); do
	if lxc-wait -t 1 -n $CONTAINER -s RUNNING; then
	    echo "Stopping '$CONTAINER'"
	    lxc-stop -n $CONTAINER
	    echo "Waiting for '$CONTAINER' to be STOPPED"
	    lxc-wait -t 10 -n $CONTAINER -s STOPPED
	fi
    done
}
# xcd container
#   Set WORKING_CONTAINER to container
#   If WORKING_CONTAINER is running then stop it
#   Destroy WORKING_CONTAINER
#
# xcd
#   If WORKING_CONTAINER is running then stop it
#   Destroy WORKING_CONTAINER
function xcd {
    if [[ -n $1 ]]; then
	echo "Setting WORKING_CONTAINER=$1"
	WORKING_CONTAINER=$1
    fi
    if lxc-wait -t 1 -n $WORKING_CONTAINER -s RUNNING; then
	echo "Killing '$WORKING_CONTAINER'"
	lxc-kill -n $WORKING_CONTAINER
	echo "Waiting for '$WORKING_CONTAINER' to be STOPPED"
	lxc-wait -t 10 -n $WORKING_CONTAINER -s STOPPED
    fi
    echo "Destroying '$WORKING_CONTAINER'"
    lxc-destroy -n $WORKING_CONTAINER
}
