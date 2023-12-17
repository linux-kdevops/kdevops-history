#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

echo $1 $2 $3 >> /tmp/kdevops-ln.log

DIR=$1
HOST=$2
IP=$3

FILES=$(find $DIR -type f -regex '.*'$IP'.*')
for i in $FILES; do
	TARGET_FILE="$(echo $i | sed -e 's|'$IP'|'$HOST'|g')"
	rm -f $TARGET_FILE
	ln -s $i $TARGET_FILE
done
