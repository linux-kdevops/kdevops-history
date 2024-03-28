#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

MIRROR_PATH="$1"

if [[ -d $MIRROR_PATH ]]; then
	echo y
	exit
fi

echo n
