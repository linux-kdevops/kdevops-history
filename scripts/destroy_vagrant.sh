#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

set -e

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

cd vagrant
vagrant destroy -f
# Make sure the user can nuke this stuff
sudo chgrp $USER . .vagrant
sudo chmod g+rwx . .vagrant
rm -rf .vagrant

# These are not initilized instances, our current directory possible
# instances. If you're running 'make destroy' you know what you are
# doing so we don't check for global dups or anything like that.
UNINIT_CURRENT_INSTANCES=$(vagrant status --machine-readable | grep ",state," | grep not_created | awk -F "," '{print $2}')
for i in $UNINIT_CURRENT_INSTANCES; do
	UNINIT_INSTANCE_SPARE_DRIVE_DIR="${CONFIG_KDEVOPS_STORAGE_POOL_PATH}/kdevops/$i"
	if [[ -d $UNINIT_INSTANCE_SPARE_DRIVE_DIR ]]; then
		echo "Found unitialized (possibly old) instance spare drive directory, removing it ... $i"
		rm -rf $UNINIT_INSTANCE_SPARE_DRIVE_DIR
	fi
done

if [[ -f $(basename "$KDEVOPS_VAGRANT_PROVISIONED") ]]; then
	rm -f $(basename "$KDEVOPS_VAGRANT_PROVISIONED") ]];
fi
