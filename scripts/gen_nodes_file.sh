#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh
source ${TOPDIR}/scripts/workflows/fstests/xfs/lib.sh

VAGRANTBOX=$CONFIG_VAGRANT_BOX
VBOXVERSION=$CONFIG_VAGRANT_BOX_VERSION

# These are shared when possible, otherwise override for your workflow
GENERIC_SPLIT_START="workflows/linux/kdevops_nodes_split_start.yaml.in"

if [[ "$CONFIG_FSTESTS_XFS" == "y" ]]; then
	xfs_generate_nodes_file
else
	generic_generate_nodes_file
fi
