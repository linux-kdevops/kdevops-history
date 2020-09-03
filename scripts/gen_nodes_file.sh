#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh
source ${TOPDIR}/scripts/workflows/fstests/xfs/lib.sh

VAGRANTBOX=$CONFIG_VAGRANT_BOX
VBOXVERSION=$CONFIG_VAGRANT_BOX_VERSION

# These are shared between filesystems
GENERIC_SPLIT_START="workflows/fstests/kdevops_nodes_split_start.yaml.in"
GENERIC_SPLIT_END="workflows/fstests/kdevops_nodes_split_end.yaml.in"

if [[ "$CONFIG_WORKFLOW_DATA_FSTYPE_XFS" == "y" ]]; then
	xfs_generate_nodes_file
else
	cat_template_nodes_sed $KDEVOPS_NODES_TEMPLATE > $KDEVOPS_NODES
fi
