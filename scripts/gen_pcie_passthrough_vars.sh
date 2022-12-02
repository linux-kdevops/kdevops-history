#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

set -e

PCIE_PREFIX_NAME="KDEVOPS_DYNAMIC_PCIE_PASSTHROUGH"
NUM_DEVICES=$CONFIG_KDEVOPS_DYNAMIC_PCIE_PASSTHROUGH_NUM_DEVICES

if [[ "$NUM_DEVICES" == "" ]]; then
	exit 1
fi

echo "pcie_passthrough_devices:"

sudo modprobe vfio-pci
QEMU_GROUP="$CONFIG_LIBVIRT_QEMU_GROUP"

sudo chgrp $QEMU_GROUP /sys/bus/pci/drivers_probe
sudo chmod 220 /sys/bus/pci/drivers_probe

for i in $(seq 1 $NUM_DEVICES); do
	PCIE_CONFIG_NAME="$(printf "CONFIG_%s_%04d" $PCIE_PREFIX_NAME $i)"
	eval ENTRY_ENABLED='$'$PCIE_CONFIG_NAME
	if [[ "$ENTRY_ENABLED" == "y" ]]; then
		eval PCIE_DOMAIN='$'"${PCIE_CONFIG_NAME}_DOMAIN"
		eval PCIE_BUS='$'"${PCIE_CONFIG_NAME}_BUS"
		eval PCIE_SLOT='$'"${PCIE_CONFIG_NAME}_SLOT"
		eval PCIE_FUNCTION='$'"${PCIE_CONFIG_NAME}_FUNCTION"
		eval PCIE_IOMMU_GROUP='$'"${PCIE_CONFIG_NAME}_IOMMUGROUP"
		eval PCIE_ID='$'"${PCIE_CONFIG_NAME}_PCI_ID"
		eval PCIE_SDEVICE='$'"${PCIE_CONFIG_NAME}_SDEVICE"
		eval PCIE_NAME='$'"${PCIE_CONFIG_NAME}_SDEVICE"
		echo "  - { domain: \"$PCIE_DOMAIN\", bus: \"$PCIE_BUS\", slot: \"$PCIE_SLOT\", function: \"$PCIE_FUNCTION\","
		echo "      pcie_id: \"$PCIE_ID\",  iommu_group: \"$PCIE_IOMMU_GROUP\","
		echo "      sdevice: \"$PCIE_SDEVICE\","
		echo "      pcie_human_name: \"$PCIE_NAME\" }"
		PCIE_DOMAIN=$(echo $PCIE_DOMAIN | sed -e 's|0x||')
		PCIE_BUS=$(echo $PCIE_BUS | sed -e 's|0x||')
		PCIE_SLOT=$(echo $PCIE_SLOT | sed -e 's|0x||')
		PCIE_FUNCTION=$(echo $PCIE_FUNCTION | sed -e 's|0x||')
	fi
done
