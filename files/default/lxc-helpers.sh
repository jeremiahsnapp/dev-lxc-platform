# Set default value of BASE_CONTAINER
export BASE_CONTAINER=s-ubuntu-1404-chef-client

# xc-base
#   Set and show BASE_CONTAINER
function xc-base {
    [[ -n $1 ]] && BASE_CONTAINER=$1
    echo $BASE_CONTAINER
}
export -f xc-base
# xc-working
#   Set and show WORKING_CONTAINER
function xc-working {
    [[ -n $1 ]] && WORKING_CONTAINER=$1
    echo $WORKING_CONTAINER
}
export -f xc-working
# xc-attach
#   Run command in WORKING_CONTAINER
#   If no arguments are given then log into WORKING_CONTAINER
function xc-attach {
    if [[ -z $WORKING_CONTAINER ]]; then
	echo "Please set the WORKING_CONTAINER first using xc-working"
	return 1
    fi
    if ! lxc-info --name $WORKING_CONTAINER > /dev/null 2>&1; then
	echo "Container '$WORKING_CONTAINER' does not exist. Please create it first."
	return 1
    fi
    if (( ! $# )); then
	echo "Logging into '$WORKING_CONTAINER' as user '$USER'"
    else
	echo "Running command in '$WORKING_CONTAINER'"
    fi
    env -i \
	LANG="en_US.UTF-8" \
	TERM="linux" \
	HOME="$HOME" \
	PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
	lxc-attach -n $WORKING_CONTAINER -- $@
}
export -f xc-attach
# xc-chroot
#   Run command in WORKING_CONTAINER chroot
function xc-chroot {
    if [[ -z $WORKING_CONTAINER ]]; then
	echo "Please set the WORKING_CONTAINER first using xc-working"
	return 1
    fi
    if ! lxc-info --name $WORKING_CONTAINER > /dev/null 2>&1; then
	echo "Container '$WORKING_CONTAINER' does not exist. Please create it first."
	return 1
    fi
    echo "Running command in '$WORKING_CONTAINER' chroot"
    chroot "/var/lib/lxc/$WORKING_CONTAINER/rootfs" $@
}
export -f xc-chroot
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
export -f xc-destroy
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
export -f xc-get-config
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
export -f xc-kill
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
export -f xc-kill-all
# xc-ls
#   Run lxc-ls with arguments given
function xc-ls {
    lxc-ls --fancy -F name,state,memory,ipv4 $@
}
export -f xc-ls
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
    if ! lxc-info --name $WORKING_CONTAINER > /dev/null 2>&1; then
	echo "Container '$WORKING_CONTAINER' does not exist. Please create it first."
	return 1
    fi
    if ! grep "^lxc.mount.entry = .* $2 " /var/lib/lxc/$WORKING_CONTAINER/config; then
	echo "Adding lxc.mount.entry to the '$WORKING_CONTAINER' config file"
	sed -i "$ a\lxc.mount.entry = $1 $2 none bind,optional,create=dir 0 0" /var/lib/lxc/$WORKING_CONTAINER/config
    else
	echo "An lxc.mount.entry already exists for that mount point in the '$WORKING_CONTAINER' config file"
    fi
}
export -f xc-mount
# xc-snapshot container1 container2
#   Set WORKING_CONTAINER to container1 and snapshot clone it into container2
#   WORKING_CONTAINER must exist and not be running
#
# xc-snapshot container
#   Snapshot clone WORKING_CONTAINER into container
#   WORKING_CONTAINER must exist and not be running
function xc-snapshot {
    if [[ -n $1 ]]; then
	if [[ -n $2 ]]; then
	    echo "Setting WORKING_CONTAINER=$1"
	    WORKING_CONTAINER=$1
	    local SNAPSHOT_CONTAINER=$2
	else
	    local SNAPSHOT_CONTAINER=$1
	fi
    fi
    if [[ -z $WORKING_CONTAINER ]]; then
	echo "Please specify a container to snapshot or set the WORKING_CONTAINER first using xc-working"
	return 1
    fi
    if [[ -z $SNAPSHOT_CONTAINER ]]; then
	echo "Please specify a name for the snapshot"
	return 1
    fi
    if ! lxc-info -n $WORKING_CONTAINER &> /dev/null; then
	echo "Aborting snapshot because container '$WORKING_CONTAINER' does not exist."
	return 1
    fi
    if lxc-info -n $SNAPSHOT_CONTAINER &> /dev/null; then
	echo "Aborting snapshot because snapshot '$SNAPSHOT_CONTAINER' already exists."
	return 1
    fi
    if ! lxc-wait -t 0 -n $WORKING_CONTAINER -s STOPPED &> /dev/null; then
	echo "Aborting snapshot because container '$WORKING_CONTAINER' is not STOPPED."
	return 1
    fi
    echo "Making a snapshot clone of '$WORKING_CONTAINER' in '$SNAPSHOT_CONTAINER'"
    lxc-clone -s -o $WORKING_CONTAINER -n $SNAPSHOT_CONTAINER
}
export -f xc-snapshot
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
	    echo "Please specify a base container or set the BASE_CONTAINER first using xc-base"
	    return 1
	fi
	echo "Cloning '$BASE_CONTAINER' into '$WORKING_CONTAINER'"
	lxc-clone -s -o $BASE_CONTAINER -n $WORKING_CONTAINER
	echo "Deleting SSH Server Host Keys"
	rm -f /var/lib/lxc/${WORKING_CONTAINER}/rootfs/etc/ssh/ssh_host*_key*
    fi
    echo "Starting '$WORKING_CONTAINER'"
    lxc-start -d -n $WORKING_CONTAINER
    echo "Waiting for '$WORKING_CONTAINER' to be RUNNING"
    lxc-wait -t 10 -n $WORKING_CONTAINER -s RUNNING

    echo "'$WORKING_CONTAINER' is RUNNING"
    echo -n "Waiting for network availability in '$WORKING_CONTAINER' "

    for i in {1..30}; do
      if lxc-attach -n $WORKING_CONTAINER --clear-env -- ip -o -f inet a show dev eth0 | grep -q eth0; then
	echo
        return 0
      fi
      echo -n .
      sleep 1
    done

    echo
    echo "WARNING: Timed out after waiting 30 seconds for network availability in '$WORKING_CONTAINER'"
    return 1
}
export -f xc-start
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
export -f xc-stop
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
export -f xc-stop-all
