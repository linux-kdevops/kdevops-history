#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

DIR=$1

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <path-to-remote-journals>"
	exit 1
fi

FILES=$(find $DIR -type f -regex '.*'$IP'.*')
PREFIX=$(grep kdevops_host_prefix extra_vars.yaml | awk -F": " '{print $2}')

REMOTE_JOURNALS=$(find $DIR -type l -regex '.*'$PREFIX'.*\.*.journal')

printf "%80s %10s %20s\n" Journal-file Filesize IP-address
for i in $REMOTE_JOURNALS; do
	echo $i | grep -q "@"
	if [[ $? -eq 0 ]]; then
		continue
	fi
	REAL=$(readlink $i)
	DU=$(du -hs $REAL | awk '{print $1}')
	IP=$(echo $REAL | sed -e 's|'$DIR'remote-||g')
	IP=$(echo $IP | sed -e 's|.journal||')
	printf "%80s %10s %20s\n" $i $DU $IP
done
