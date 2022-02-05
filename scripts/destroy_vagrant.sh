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
