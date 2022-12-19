#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

MIRROR_PATH="/mirror/"

if [[ -d $MIRROR_PATH ]]; then
	MIRROR_COUNT="$(ls -1 $MIRROR_PATH | wc -l)"
	if [[ "$1" == "ENABLE_LOCAL_LINUX_MIRROR" ]]; then
		echo y
		exit
	fi
	if [[ "$1" == "USE_LOCAL_LINUX_MIRROR" ]]; then
		if [[ "$MIRROR_COUNT" -ne 0 ]]; then
			echo y
			exit
		fi
	fi
	if [[ "$1" == "INSTALL_LOCAL_LINUX_MIRROR" ]]; then
		echo KDEVOPS_FIRST_RUN
		exit
	fi
fi

echo n
