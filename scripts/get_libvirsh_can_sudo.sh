#!/bin/bash
# Let's us use advanced heuristics for lazy developers where sudo is already
# set. These heuristics are typically for lage deployments of kdevops where
# you may use different libvirt storage pools for different nvme drives and
# you want kdevops to automatically detect the ideal storage pool for you
# based on your current working directly. If passwordless sudo does not work
# these heuristics are disabled. With a tiny bit of testing this could likely
# be enabled / tested for libvirt with user sessions.

SCRIPTS_DIR=$(dirname $0)
source ${SCRIPTS_DIR}/libvirt_pool.sh

BASE_DIR=$(echo ${PWD} | awk -F"/" '{print $2}')
OS_FILE="/etc/os-release"
USES_QEMU_USER_SESSION="n"
CAN_SUDO="n"
REQ_SUDO=""
POOL_LIST=""

if [[ "$CAN_SUDO" == "n" ]]; then
	echo n
	exit
fi
echo y
