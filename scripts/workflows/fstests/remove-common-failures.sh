#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

# Takes as input a directory with expunge files, it will look for all.txt for
# common failures, and then only output entries which are not
# present in the commmon all.txt file.

usage()
{
	echo "$0: <directory-with-expunges-to-remove-common-entries-from>"
}

if [[ $# -ne 1 ]]; then
	usage
	exit
fi

DIR=$1
if [[ ! -d $DIR ]]; then
	echo "Path supplied must be a directory, but it is not: $DIR"
	exit
fi

COMMON="$DIR/all.txt"
FILES=$(find $DIR -type f | grep -v 'all.txt')

if [[ ! -f $COMMON ]]; then
	echo "Common file does not exist: $COMMON"
	exit 1
fi

COMMON_EXPUNGES=""

for expunge in $(cat $COMMON | awk '{print $1}'); do
	if [[ "$COMMON_EXPUNGES" == "" ]]; then
		COMMON_EXPUNGES="$expunge"
		continue
	fi
	COMMON_EXPUNGES="$COMMON_EXPUNGES|$expunge"
done

TMP_FILE=$(mktemp)
for i in $FILES; do
	cat $i | egrep -v "${COMMON_EXPUNGES[@]}" | sort | uniq > $TMP_FILE
	mv $TMP_FILE $i
	SIZE=$(du -b $i | awk '{print $1}')
	if [[ -d .git ]]; then
		if [[ $SIZE == "0" ]]; then
			git rm -f $i
		fi
	fi
done

exit 0
