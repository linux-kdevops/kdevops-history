#!/bin/bash

CUR_VAL=$1
which nc &> /dev/null
if [[ $? -ne 0 ]]; then
	echo y
	exit
fi

# change to port 9419 to verify this will fail if your firewall does not
# allow git access.
nc -v -z -w 3 git.kernel.org 9418 &> /dev/null
if [[ $? -eq 0 ]]; then
	echo y
else
	echo n
fi
