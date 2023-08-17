#!/bin/bash

VARS="extra_vars.yaml"
LAST_KERNEL_FILE="workflows/fstests/results/last-kernel.txt"

FILE_REQS="$VARS"
FILE_REQS="$FILE_REQS $LAST_KERNEL_FILE"

for i in $FILE_REQS; do
	if [ ! -f "$i" ]; then
		echo "Missing $i"
		exit 1
	fi
done

LAST_KERNEL=$(cat $LAST_KERNEL_FILE | sed -e 's/ //g')
if ! grep -q ^fstests_fstyp $VARS; then
	echo "You do not have fstests_fsty on $VARS"
	exit 1
fi

RESULTS_TARBALL="workflows/fstests/results/${LAST_KERNEL}.xz"
if [ ! -f $RESULTS_TARBALL ]; then
	echo "Missing results tarball: $RESULTS_TARBALL"
	exit 1
fi

FSTYP=$(grep fstests_fstyp $VARS | awk -F":" '{print $2}' | sed -e 's/ //g')

echo "Filesystem:     $FSTYP"
echo "Kernel tested:  $LAST_KERNEL"

if [[ "$FSTYP" == "" ]]; then
	echo "Missing fstests_fstyp variable setting on $VARS"
	exit 1
fi

TYPE="libvirt-qemu"
if ! grep -q "libvirt_provider: True" $VARS; then
	TYPE="cloud"
	if ! grep -q terraform; then
		TYPE="custom"
	fi
fi

TODAY="$(date -I| sed -e 's|-||g')"
MY_DIR="workflows/fstests/results/$USER/$FSTYP/$TYPE/$TODAY"

echo -e "\nRunning:\n"

echo mkdir -p $MY_DIR
echo cp $RESULTS_TARBALL $MY_DIR
echo cp .config $MY_DIR/kdevops.config

