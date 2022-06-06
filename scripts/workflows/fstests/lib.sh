#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

FS_CONFIG_FILE=${TOPDIR}/playbooks/roles/fstests/templates/${FSTYP}/${FSTYP}.config

check_fs_config()
{
	if [[ ! -f $FS_CONFIG_FILE ]]; then
		echo "Filesystem configuration $FS_CONFIG_FILE does not exist"
		exit 1
	fi
}

get_fs_sections()
{
	local FS=$1
	local FS_SECTIONS=""

	if [[ ! -d ${TOPDIR}/workflows/fstests/${FS} ]]; then
		echo "Invalid filesystem as there is no configuration for it: $FS"
		exit 1
	fi

	FS_SECTIONS=$(grep "^\[" ${FS_CONFIG_FILE})
	FS_SECTIONS=$(echo "$FS_SECTIONS" | grep -v "^\[default")
	FS_SECTIONS=$(echo "$FS_SECTIONS" | sed -e 's|\[||g' | sed -e 's|\]||g')
	FS_SECTIONS=$(echo "$FS_SECTIONS" | awk -F"${FS}_" '{print $2}')

	echo $FS_SECTIONS
}
