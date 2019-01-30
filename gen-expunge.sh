#!/bin/bash
# Generates expunge file output based on log passed.

usage()
{
	echo "Usage: $0 <logfile>"
}

if [ $# -ne 1 ]; then
	usage
	exit
fi

LOG_FILE=$1

if [ ! -f $LOG_FILE ]; then
	echo "No logfile found: $LOG_FILE"
fi

for i in $(grep ^Fail $LOG_FILE | head -1); do
	echo $i
done
