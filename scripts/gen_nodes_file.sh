#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh
source ${TOPDIR}/scripts/workflows/fstests/xfs/lib.sh
source ${TOPDIR}/scripts/workflows/fstests/btrfs/lib.sh
source ${TOPDIR}/scripts/workflows/fstests/ext4/lib.sh
source ${TOPDIR}/scripts/workflows/blktests/lib.sh

VAGRANTBOX=$CONFIG_VAGRANT_BOX
VBOXVERSION=$CONFIG_VAGRANT_BOX_VERSION

# These are shared when possible, otherwise override for your workflow
GENERIC_SPLIT_START="workflows/linux/kdevops_nodes_split_start.yaml.in"

if [[ "$CONFIG_KDEVOPS_WORKFLOW_ENABLE_BLKTESTS" == "y" ]]; then
	blktests_generate_nodes_file
	exit
fi

if [[ "$CONFIG_FSTESTS_XFS" == "y" ]]; then
	xfs_generate_nodes_file
elif [[ "$CONFIG_FSTESTS_BTRFS" == "y" ]]; then
	btrfs_generate_nodes_file
elif [[ "$CONFIG_FSTESTS_EXT4" == "y" ]]; then
	ext4_generate_nodes_file
else
	generic_generate_nodes_file
fi
