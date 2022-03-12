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
QEMUBINPATH=$CONFIG_QEMU_BIN_PATH
NVMEZONEDRIVESIZE=$CONFIG_QEMU_NVME_ZONE_DRIVE_SIZE
NVMEZONEZASL=$CONFIG_QEMU_NVME_ZONE_ZASL
NVMEZONESIZE=$CONFIG_QEMU_NVME_ZONE_SIZE
NVMEZONECAPACITY=$CONFIG_QEMU_NVME_ZONE_CAPACITY
NVMEZONEMAXACTIVE=$CONFIG_QEMU_NVME_ZONE_MAX_ACTIVE
NVMEZONEMAXOPEN=$CONFIG_QEMU_NVME_ZONE_MAX_OPEN
NVMEZONEPHYSICALBLOCKSIZE=$CONFIG_QEMU_NVME_ZONE_PHYSICAL_BLOCKSIZE
NVMEZONELOGICALBLOCKSIZE=$CONFIG_QEMU_NVME_ZONE_LOGICAL_BLOCKSIZE

# These are shared when possible, otherwise override for your workflow
GENERIC_SPLIT_START="workflows/linux/kdevops_nodes_split_start.yaml.in"

gen_nodes_dedicated()
{
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
}

if [[ "$CONFIG_WORKFLOWS_DEDICATED_WORKFLOW" = "y" ]]; then
	gen_nodes_dedicated
else
	generic_generate_nodes_file
fi
