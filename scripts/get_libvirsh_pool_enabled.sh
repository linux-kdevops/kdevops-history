#!/bin/bash
# Tries to infer if you should be using your existing storage pool paths.
# If you are using kdevops in a directory like say /data1/next/kdevops
# this will look to see if /data1/ is the path of any storage pool and if
# so enable the pool path and pool path heuristic.
#
# If you don't have libvirt set up or need access to the libvir to storage
# pool path information this heuristic will be disabled.

SCRIPTS_DIR=$(dirname $0)
source ${SCRIPTS_DIR}/libvirt_pool.sh

BASE_DIR=$(echo ${PWD} | awk -F"/" '{print $2}')
OS_FILE="/etc/os-release"
USES_QEMU_USER_SESSION="n"
CAN_SUDO="n"
REQ_SUDO=""
POOL_LIST=""

get_pool_vars
VIRSH_WORKS=$(virsh_works)
if [[ "$VIRSH_WORKS" == "n" ]]; then
	echo n
	exit
fi

virsh_get_pool_list
virsh_path_in_pool_list_exists
