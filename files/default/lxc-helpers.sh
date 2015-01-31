# Set default value of BASE_CONTAINER
export BASE_CONTAINER=p-ubuntu-1404-chef-client

# xc-base
#   Set and show BASE_CONTAINER
function xc-base {
    [[ -n $1 ]] && BASE_CONTAINER=$1
    echo $BASE_CONTAINER
}
# xc-working
#   Set and show WORKING_CONTAINER
function xc-working {
    [[ -n $1 ]] && WORKING_CONTAINER=$1
    echo $WORKING_CONTAINER
}
# xc-attach
#   Run command in WORKING_CONTAINER
#   If no arguments are given then log into WORKING_CONTAINER
function xc-attach {
    if (( ! $# )); then
	echo "Logging into '$WORKING_CONTAINER' as user '$USER'"
    else
	echo "Running command in '$WORKING_CONTAINER'"
    fi
    if [[ -z $WORKING_CONTAINER ]]; then
	echo "Please set the WORKING_CONTAINER first using xc-working"
	return 1
    fi
    lxc-attach -n $WORKING_CONTAINER --keep-env -- $@
}
# xc-chroot
#   Run command in WORKING_CONTAINER chroot
function xc-chroot {
    if [[ -z $WORKING_CONTAINER ]]; then
	echo "Please set the WORKING_CONTAINER first using xc-working"
	return 1
    fi
    echo "Running command in '$WORKING_CONTAINER' chroot"
    chroot "/var/lib/lxc/$WORKING_CONTAINER/rootfs" $@
}
# xc-chef-install chef_version
#   Install specific version of Chef in WORKING_CONTAINER
#
# xc-chef-install
#   Install latest version of  Chef in WORKING_CONTAINER
function xc-chef-install {
    if [[ -n $1 ]]; then
	local CHEF_VERSION="-v $1"
    fi
    if [[ -z $WORKING_CONTAINER ]]; then
	echo "Please set the WORKING_CONTAINER first using xc-working"
	return 1
    fi
    if ! lxc-wait -t 1 -n $WORKING_CONTAINER -s RUNNING; then
	echo "Please start '$WORKING_CONTAINER' before running this command"
	return 1
    fi
    echo "Installing Chef $1 on '$WORKING_CONTAINER'"
    curl -L https://www.opscode.com/chef/install.sh | lxc-attach -n $WORKING_CONTAINER --keep-env -- bash -s -- $CHEF_VERSION
}
# xc-chef-zero container
#   Set WORKING_CONTAINER to container
#   Configure WORKING_CONTAINER to work with chef-zero
#
# xc-chef-zero
#   Configure WORKING_CONTAINER to work with chef-zero
function xc-chef-zero {
    if [[ -n $1 ]]; then
	echo "Setting WORKING_CONTAINER=$1"
	WORKING_CONTAINER=$1
    fi
    if [[ -z $WORKING_CONTAINER ]]; then
	echo "Please set the WORKING_CONTAINER first using xc-working"
	return 1
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
# xc-destroy container
#   Set WORKING_CONTAINER to container
#   If WORKING_CONTAINER is running then kill it
#   Destroy WORKING_CONTAINER
#
# xc-destroy
#   If WORKING_CONTAINER is running then kill it
#   Destroy WORKING_CONTAINER
function xc-destroy {
    if [[ -n $1 ]]; then
	echo "Setting WORKING_CONTAINER=$1"
	WORKING_CONTAINER=$1
    fi
    if [[ -z $WORKING_CONTAINER ]]; then
	echo "Please set the WORKING_CONTAINER first using xc-working"
	return 1
    fi
    if lxc-wait -t 1 -n $WORKING_CONTAINER -s RUNNING; then
	echo "Killing '$WORKING_CONTAINER'"
	lxc-stop -k -n $WORKING_CONTAINER
	echo "Waiting for '$WORKING_CONTAINER' to be STOPPED"
	lxc-wait -t 10 -n $WORKING_CONTAINER -s STOPPED
    fi
    echo "Destroying '$WORKING_CONTAINER'"
    lxc-destroy -n $WORKING_CONTAINER
}
# xc-get-config container
#   Set WORKING_CONTAINER to container
#   Print the path of the WORKING_CONTAINER config file
#
# xc-get-config
#   Print the path of the WORKING_CONTAINER config file
function xc-get-config {
    if [[ -n $1 ]]; then
	echo "Setting WORKING_CONTAINER=$1"
	WORKING_CONTAINER=$1
    fi
    if [[ -z $WORKING_CONTAINER ]]; then
	echo "Please set the WORKING_CONTAINER first using xc-working"
	return 1
    fi
    if [[ -a "/var/lib/lxc/$WORKING_CONTAINER/config" ]]; then
	echo "/var/lib/lxc/$WORKING_CONTAINER/config"
    else
	echo "No config file exists for container '$WORKING_CONTAINER'"
    fi
}
# xc-kill container
#   Set WORKING_CONTAINER to container
#   Kill WORKING_CONTAINER
#
# xc-kill
#   Kill WORKING_CONTAINER
function xc-kill {
    if [[ -n $1 ]]; then
	echo "Setting WORKING_CONTAINER=$1"
	WORKING_CONTAINER=$1
    fi
    if [[ -z $WORKING_CONTAINER ]]; then
	echo "Please set the WORKING_CONTAINER first using xc-working"
	return 1
    fi
    echo "Killing '$WORKING_CONTAINER'"
    lxc-stop -k -n $WORKING_CONTAINER
}
# xc-kill-all
#   Kill all containers
function xc-kill-all {
    for CONTAINER in $(lxc-ls -1); do
	if lxc-wait -t 1 -n $CONTAINER -s RUNNING; then
	    echo "Killing '$CONTAINER'"
	    lxc-stop -k -n $CONTAINER
	    echo "Waiting for '$CONTAINER' to be STOPPED"
	    lxc-wait -t 10 -n $CONTAINER -s STOPPED
	fi
    done
}
# xc-ls
#   Run lxc-ls with arguments given
#   If no arguments are given the default to --fancy
function  xc-ls {
    if (( ! $# )); then
	lxc-ls --fancy
    else
	lxc-ls $@
    fi
}
# xc-mount host_path container_mount_point
#   Create the mount point in WORKING_CONTAINER if it does not exist
#   Add mount configuration to the WORKING_CONTAINER config file
function xc-mount {
    if (( $# != 2 )); then
	echo "Please specify the host_path and container_mount_point"
	return 1
    fi
    if [[ -z $WORKING_CONTAINER ]]; then
	echo "Please set the WORKING_CONTAINER first using xc-working"
	return 1
    fi
    if ! grep "^lxc.mount.entry = .* $2 " /var/lib/lxc/$WORKING_CONTAINER/config; then
	echo "Adding lxc.mount.entry to the '$WORKING_CONTAINER' config file"
	sed -i "$ a\lxc.mount.entry = $1 $2 none bind,create=dir 0 0" /var/lib/lxc/$WORKING_CONTAINER/config
    else
	echo "An lxc.mount.entry already exists for that mount point in the '$WORKING_CONTAINER' config file"
    fi
}
# xc-start container1 container2
#   Set BASE_CONTAINER to container1 and WORKING_CONTAINER to container2
#   If WORKING_CONTAINER does not exist then clone BASE_CONTAINER to WORKING_CONTAINER
#   Start WORKING_CONTAINER
#
# xc-start container
#   Set WORKING_CONTAINER to container
#   If WORKING_CONTAINER does not exist then clone BASE_CONTAINER to WORKING_CONTAINER
#   Start WORKING_CONTAINER
#
# xc-start
#   If WORKING_CONTAINER does not exist then clone BASE_CONTAINER to WORKING_CONTAINER
#   Start WORKING_CONTAINER
function xc-start {
    if [[ -n $1 ]]; then
	if [[ -n $2 ]]; then
	    echo "Setting BASE_CONTAINER=$1"
	    BASE_CONTAINER=$1
	    echo "Setting WORKING_CONTAINER=$2"
	    WORKING_CONTAINER=$2
	else
	    echo "Setting WORKING_CONTAINER=$1"
	    WORKING_CONTAINER=$1
	fi
    fi
    if [[ -z $WORKING_CONTAINER ]]; then
	echo "Please set the WORKING_CONTAINER first using xc-working"
	return 1
    fi
    if ! lxc-info -n $WORKING_CONTAINER &> /dev/null; then
	if [[ -z $BASE_CONTAINER ]]; then
	    echo "Please set the WORKING_CONTAINER first using xc-working"
	    return 1
	fi
	echo "Cloning '$BASE_CONTAINER' into '$WORKING_CONTAINER'"
	lxc-clone -s -o $BASE_CONTAINER -n $WORKING_CONTAINER
    fi
    echo "Starting '$WORKING_CONTAINER'"
    lxc-start -d -n $WORKING_CONTAINER
    echo "Waiting for '$WORKING_CONTAINER' to be RUNNING"
    lxc-wait -t 10 -n $WORKING_CONTAINER -s RUNNING
}
# xc-stop container
#   Set WORKING_CONTAINER to container
#   Stop WORKING_CONTAINER
#
# xc-stop
#   Stop WORKING_CONTAINER
function xc-stop {
    if [[ -n $1 ]]; then
	echo "Setting WORKING_CONTAINER=$1"
	WORKING_CONTAINER=$1
    fi
    if [[ -z $WORKING_CONTAINER ]]; then
	echo "Please set the WORKING_CONTAINER first using xc-working"
	return 1
    fi
    echo "Stopping '$WORKING_CONTAINER'"
    lxc-stop -n $WORKING_CONTAINER
}
# xc-stop-all
#   Stop all containers
function xc-stop-all {
    for CONTAINER in $(lxc-ls -1); do
	if lxc-wait -t 1 -n $CONTAINER -s RUNNING; then
	    echo "Stopping '$CONTAINER'"
	    lxc-stop -n $CONTAINER
	    echo "Waiting for '$CONTAINER' to be STOPPED"
	    lxc-wait -t 10 -n $CONTAINER -s STOPPED
	fi
    done
}
