#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

if [[ "$TOPDIR" == "" ]]; then
	TOPDIR=$PWD
fi

TARGET_WORKFLOW="$(basename $(dirname $0))"
echo $TARGET_WORKFLOW

if [[ ! -f ${TOPDIR}/.config || ! -f ${TOPDIR}/scripts/lib.sh ]]; then
	echo "Unconfigured system"
	exit 1
fi

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

rm -f ${TOPDIR}/.kotd.*

TARGET_HOSTS="baseline"
if [[ "$1" != "" ]]; then
	TARGET_HOSTS=$1
fi

kotd_log()
{
	NOW=$(date --rfc-3339='seconds' | awk -F"+" '{print $1}')
	echo "$NOW : $@" >> $KOTD_LOG
}

KOTD_LOOP_COUNT=1

kotd_log "Begin KOTD work"

while true; do
	kotd_log "***********************************************************"
	kotd_log "Begin KOTD loop #$KOTD_LOOP_COUNT"
	kotd_log "---------------------------------"

	kotd_log "Going to try to rev kernel"
	/usr/bin/time -f %E -o $KOTD_LOGTIME_FULL make kotd-${TARGET_HOSTS}
	if [[ $? -ne 0 ]]; then
		kotd_log "failed running: make kotd-$TARGET_HOSTS"
		if [[ -f $KOTD_BEFORE ]]; then
			KERNEL_BEFORE="$(cat $KOTD_BEFORE)"
			kotd_log "KOTD before: $KERNEL_BEFORE"
		fi
		if [[ -f $KOTD_AFTER ]]; then
			KERNEL_AFTER="$(cat $KOTD_BEFORE)"
			kotd_log "KOTD after: $KERNEL_AFTER"
		fi
		THIS_KOTD_LOGTIME=$(cat $KOTD_LOGTIME_FULL)
		kotd_log "KOTD reving work failed after this amount of time: $THIS_KOTD_LOGTIME"
		exit 1
	fi

	THIS_KOTD_LOGTIME=$(cat $KOTD_LOGTIME_FULL)
	kotd_log "KOTD reving work succeeded after this amount of time: $THIS_KOTD_LOGTIME"

	if [[ -f $KOTD_BEFORE ]]; then
		KERNEL_BEFORE="$(cat $KOTD_BEFORE)"
		kotd_log "KOTD before: $KERNEL_BEFORE"
	fi
	if [[ -f $KOTD_AFTER ]]; then
		KERNEL_AFTER="$(cat $KOTD_BEFORE)"
		kotd_log "KOTD after: $KERNEL_AFTER"
	fi

	kotd_log "Going to try to run the $TARGET_WORKFLOW kernel-ci loop"
	/usr/bin/time -f %E -o $KOTD_LOGTIME_FULL make $TARGET_WORKFLOW-${TARGET_HOSTS}-loop
	if [[ $? -ne 0 ]]; then
		kotd_log "failed running: make $TARGET_WORKFLOW-${TARGET_HOSTS}-loop"
		THIS_KOTD_LOGTIME=$(cat $KOTD_LOGTIME_FULL)
		kotd_log "$TARGET_WORKFLOW kernel-ci work failed after this amount of time: $THIS_KOTD_LOGTIME"
	fi
	THIS_KOTD_LOGTIME=$(cat $KOTD_LOGTIME_FULL)
	kotd_log "Completed kernel-ci loop work for $TARGET_WORKFLOW successfully after this amount of time: $THIS_KOTD_LOGTIME"
	let KOTD_LOOP_COUNT=$KOTD_LOOP_COUNT+1
done
