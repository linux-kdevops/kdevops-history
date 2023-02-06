#!/bin/bash
# Tries to infer your preferred libvirt storage pool name.
# If you are using kdevops in a directory like say /data1/next/kdevops
# this will look to see if /data1/ is the path of a storage pool name
# and if so return that name.

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
	echo "default"
	exit
fi

virsh_get_pool_list

DOES_POOL_EXIST=$(virsh_path_in_pool_list_exists)
if [[ "$DOES_POOL_EXIST" != "y" ]]; then
	echo "default"
	exit
fi

virsh_path_pool_list_name
