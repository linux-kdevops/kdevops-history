#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

# This hack lets us e
KCONFIG_DIR=$1
for i in $(find $KCONFIG_DIR/ -name Kconfig\.*); do
	echo "\$\(info, source \"$i\"\)
done
