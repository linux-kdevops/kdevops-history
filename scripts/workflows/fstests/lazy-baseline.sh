#!/bin/bash

VARS="extra_vars.yaml"
LAST_KERNEL_FILE="workflows/fstests/results/last-kernel.txt"
EXPUNGE_BASE="workflows/fstests/expunges"
DEFAULT_PRIORITY="unassigned"
FIND_COMMON="./scripts/workflows/fstests/find-common-failures.sh"
REMOVE_COMMON="./scripts/workflows/fstests/remove-common-failures.sh"

FILE_REQS="$VARS"
FILE_REQS="$FILE_REQS $LAST_KERNEL_FILE"
FILE_REQS="$FILE_REQS ./scripts/workflows/fstests/find-common-failures.sh"
FILE_REQS="$FILE_REQS ./scripts/workflows/fstests/remove-common-failures.sh"

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

FSTYP=$(grep fstests_fstyp $VARS | awk -F":" '{print $2}' | sed -e 's/ //g')

echo "Filesystem:     $FSTYP"
echo "Kernel tested:  $LAST_KERNEL"

if [[ "$FSTYP" == "" ]]; then
	echo "Missing fstests_fstyp variable setting on $VARS"
	exit 1
fi

EXPUNGE_DIR="$EXPUNGE_BASE/$LAST_KERNEL/$FSTYP/$DEFAULT_PRIORITY/"

echo -e "\nRunning:\n"

echo $FIND_COMMON -l $EXPUNGE_DIR
echo $REMOVE_COMMON  $EXPUNGE_DIR

$FIND_COMMON -l $EXPUNGE_DIR
$REMOVE_COMMON  $EXPUNGE_DIR
