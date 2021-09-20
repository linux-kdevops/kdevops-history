#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

# Takes as input an expunge file, it will look for all.txt for
# common failures, and then only output entries which are not
# present in the commmon all.txt file.

usage()
{
	echo "$0: <expunge-file-to-remove-common-entries-from>"
}

if [[ $# -ne 1 ]]; then
	usage
	exit
fi

FILE=$1
if [[ ! -f $FILE ]]; then
	echo "Path supplied must be a file, but it is not: $FILE"
	exit
fi

DIR=$(dirname $FILE)
COMMON="$DIR/all.txt"

if [[ ! -f $COMMON ]]; then
	echo "Common file does not exist: $COMMON"
	exit 1
fi

COMMON_EXPUNGES=""

LAST_ENTRY="$(cat $COMMON | tail -1)"
for expunge in $(cat $COMMON); do
	if [[ "$COMMON_EXPUNGES" == "" ]]; then
		COMMON_EXPUNGES="$expunge"
		continue
	fi
	COMMON_EXPUNGES="$COMMON_EXPUNGES|$expunge"
done

cat $FILE | egrep -v "${COMMON_EXPUNGES[@]}" | sort | uniq

exit 0
