#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

DISTRO_REGCODE_SCRIPT="${TOPDIR}/scripts/get_distro_regcode_$1.sh"

if [ -s "$DISTRO_REGCODE_SCRIPT" ]; then
	$DISTRO_REGCODE_SCRIPT
else
	echo "Unset"
fi
