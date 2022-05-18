#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

set -e

if [ $# -le 0 ]
then
	echo "Must specify PCI id's to modify"
	echo $#
	exit 1
fi

sudo modprobe vfio-pci
sudo chgrp libvirt /sys/bus/pci/drivers_probe
sudo chmod 220 /sys/bus/pci/drivers_probe

# cd to our current directory so we can copy the udev rule into place
cd $(dirname $0)
sudo cp 10-qemu-hw-users.rules /etc/udev/rules.d/

for DEV in $@; do
	sudo chgrp libvirt /sys/bus/pci/devices/$DEV/driver_override
	sudo chmod 664 /sys/bus/pci/devices/$DEV/driver_override
	sudo chgrp libvirt /sys/bus/pci/devices/$DEV/driver/unbind
	sudo chmod 220 /sys/bus/pci/devices/$DEV/driver/unbind
done
