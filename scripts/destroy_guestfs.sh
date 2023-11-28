#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

[ -z "${TOPDIR}" ] && TOPDIR='.'
source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

STORAGEDIR="${CONFIG_KDEVOPS_STORAGE_POOL_PATH}/kdevops/guestfs"
GUESTFSDIR="${TOPDIR}/guestfs"

if [ -f "$GUESTFSDIR/kdevops_nodes.yaml" ]; then
	# FIXME: is there a yaml equivalent to jq ?
	grep -e '^  - name: ' "${GUESTFSDIR}/kdevops_nodes.yaml"  | sed 's/^  - name: //' | while read name
	do
		domstate=$(virsh domstate $name 2>/dev/null)
		if [ $? -eq 0 ]; then
			if [ "$domstate" = 'running' ]; then
				virsh destroy $name
			fi
			virsh undefine $name
		fi
		rm -rf "$GUESTFSDIR/$name"
		rm -rf "$STORAGEDIR/$name"
	done
fi

rm -f ~/.ssh/config_kdevops_$CONFIG_KDEVOPS_HOSTS_PREFIX
rm -f $GUESTFSDIR/.provisioned_once
rm -f $GUESTFSDIR/kdevops_nodes.yaml
