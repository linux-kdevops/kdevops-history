#!/bin/bash

DEFAULT_DISTRO="debian"
DISTROS="debian"
DISTROS="$DISTROS fedora"
DISTROS="$DISTROS opensuse"
DISTROS="$DISTROS redhat"
DISTROS="$DISTROS suse"
DISTROS="$DISTROS ubuntu"

for i in $DISTROS; do
	if [[ "./scripts/os-release-check.sh $i" == "y" ]]; then
		echo $i
		exit
	fi
done

echo $DEFAULT_DISTRO
