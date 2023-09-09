#!/bin/bash

usage()
{
	echo "Usage: $0 <expunge-kernel-directory>"
	exit 0
}

if [[ $# -ne 1 ]]; then
	usage
fi

if [[ $1 == "--help" || $1 == "-h" ]]; then
	usage
fi

DIR=$1

if [[ ! -d $DIR ]]; then
	echo "$DIR is not a directory"
	usage
fi

FILES=$(find $DIR -name \*.txt)

for i in $FILES; do
	TMP=${i}.tmp
	if [ -L $i ]; then
		continue
	fi
	cat $i | sort | uniq > $TMP
	mv $TMP $i
done
