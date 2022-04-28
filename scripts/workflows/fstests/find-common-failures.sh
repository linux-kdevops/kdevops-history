#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1
# Takes an expunge directory as input and outputs all
# common expunges between them.

LAZY_BASELINE="n"
DIR=""

usage()
{
	echo "Usage: $0 [-l | --lazy-baseline ] <directory-with-expunges>"
	echo ""
	echo "-l | --lazy-baseline  If an expunge is found present in at least two sections expunge it from all sections"
	echo ""
}

if [[ $# -le 1 ]]; then
	usage
	exit
fi

parse_args()
{
	while [[ $# -gt 0 ]]; do
	key="$1"

	case $key in
		-l|--lazy-baseline)
		LAZY_BASELINE="y"
		shift
		;;
	*)
		DIR=$1
		shift
		;;
	esac
	done
}

parse_args $@

if [[ $DIR == "" ]]; then
	usage
	exit
fi

if [[ ! -d $DIR ]]; then
	echo "Path supplied must be a directory, but it is not: $DIR"
	exit
fi

FILES=$(find $DIR -type f | grep -v 'all.txt')
COUNT=$(find $DIR -type f | grep -v 'all.txt'| wc -l)
COMMON_EXPUNGES=()
TMP_FILE=$(mktemp)

for f in $FILES; do
	for expunge in $(cat $f | awk '{print $1}'); do
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
		if [[ "$LAZY_BASELINE" == "y" ]]; then
			if [[ $EXPUNGE_COUNT -ge 2 ]]; then
				COMMON_EXPUNGES+=( $expunge )
			fi
		elif [[ $EXPUNGE_COUNT -eq $COUNT ]]; then
			COMMON_EXPUNGES+=( $expunge )
		fi
	done
done

print_all_common_expunges()
{
	for i in ${COMMON_EXPUNGES[@]}; do
		if [[ "$LAZY_BASELINE" == "y" ]]; then
			echo "$i # lazy baseline - failure found in at least two sections"
		else
			echo $i
		fi
	done
}

print_all_common_expunges | sort | uniq > $TMP_FILE
cat $TMP_FILE >> $DIR/all.txt
sort $DIR/all.txt | uniq > $TMP_FILE
mv $TMP_FILE $DIR/all.txt

exit 0
