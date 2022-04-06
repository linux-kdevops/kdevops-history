#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1
# Takes an expunge directory as input and outputs all
# common expunges between them.
usage()
{
	echo "$0: <directory-with-expunges>"
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

FILES=$(find $DIR -type f | grep -v 'all.txt')
COUNT=$(find $DIR -type f | grep -v 'all.txt'| wc -l)
COMMON_EXPUNGES=()
TMP_FILE=$(mktemp)

for f in $FILES; do
	for expunge in $(cat $f); do
		EXPUNGE_COUNT=1
		for f2 in $FILES; do
			if [[ "$f2" == "$f" ]]; then
				continue
			fi
			grep -q $expunge $f2
			if [[ $? -eq 0 ]]; then
				let EXPUNGE_COUNT=$EXPUNGE_COUNT+1
			fi
		done
		if [[ $EXPUNGE_COUNT -eq $COUNT ]]; then
			COMMON_EXPUNGES+=( $expunge )
		fi
	done
done

print_all_common_expunges()
{
	for i in ${COMMON_EXPUNGES[@]}; do
		echo $i
	done
}

print_all_common_expunges | sort | uniq > $TMP_FILE
cat $TMP_FILE >> $DIR/all.txt
rm -f $TMP_FILE

exit 0
