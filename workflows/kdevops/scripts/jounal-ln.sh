#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

DIR=$1
HOST=$2
IP=$3

# remove broken symlinks
find $DIR -xtype l ! -type f -exec rm {} \;

FILES=$(find $DIR -type f -regex '.*'$IP'.*')
for i in $FILES; do
	TARGET_FILE="$(echo $i | sed -e 's|'$IP'|'$HOST'|g')"
	rm -f $TARGET_FILE
	ln -s $i $TARGET_FILE
done
