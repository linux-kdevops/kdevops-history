#!/bin/bash
# Looks to see if a vagrant box is present
# Vagrant lacks the ability to tell you if a box is present in one
# single command line so we have to wrap this up for it.

TMP_FILE=""

box_search_finish()
{
	if [[ ! -z $TMP_FILE ]]; then
		rm -f $TMP_FILE
	fi
}

trap "box_search_finish" EXIT

if [[ $# -ne 2 ]]; then
	echo "Usage: $0 <box_name> <box_url>"
	exit 1
fi

BOX=$1
BOX_URL=$2

BOX_SEARCH="$1\s\+"
TMP_FILE=$(mktemp)

vagrant box list > $TMP_FILE
grep -q "$BOX_SEARCH" $TMP_FILE
if [ $? -eq 0 ] ; then
	exit 0
else
	vagrant box add --name $BOX $BOX_URL
	RET=$?
	# We use a special return value to indicate change to the
	# ansible script, so that it can tell a change has occurred.
	if [ $RET -eq 0 ]; then
		exit 314
	fi
	exit $RET
fi
