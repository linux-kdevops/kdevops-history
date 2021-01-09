#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

FSTYPE="$CONFIG_FSTESTS_FSTYP"
RCPT="ignore@test.com"
SSH_TARGET="ignore"
KERNEL_CI_LOOP="${TOPDIR}/scripts/workflows/fstests/run_loop.sh"

if [[ "$CONFIG_KERNEL_CI_EMAIL_REPORT" == "y" ]]; then
	RCPT="$CONFIG_KERNEL_CI_EMAIL_RCPT"
	if [[ "$CONFIG_KERNEL_CI_EMAIL_METHOD_SSH" == "y" ]]; then
		SSH_TARGET="$CONFIG_KERNEL_CI_EMAIL_SSH_HOST"
	fi
fi

SUBJECT_PREFIX="kernel-ci: fstests failure for $FSTYPE on test loop "

/usr/bin/time -f %E -o $KERNEL_CI_LOGTIME_FULL $KERNEL_CI_LOOP
echo "-------------------------------------------" >> $KERNEL_CI_LOGTIME_FULL
echo "Full run time of kernel-ci loop:" >> $KERNEL_CI_LOGTIME_FULL
cat $KERNEL_CI_LOGTIME_FULL >> $KERNEL_CI_FAIL_LOG

echo "-------------------------------------------" >> $KERNEL_CI_DIFF_LOG
echo "Full run time of kernel-ci loop:" >> $KERNEL_CI_DIFF_LOG
cat $KERNEL_CI_LOGTIME_FULL >> $KERNEL_CI_DIFF_LOG

if [[ "$CONFIG_KERNEL_CI_EMAIL_REPORT" != "y" ]]; then
	if [[ -f $KERNEL_CI_FAIL_FILE ]]; then
		FAIL_LOOP="$(cat $KERNEL_CI_FAIL_FILE)"
		SUBJECT="$SUBJECT_PREFIX $FAIL_LOOP"
		echo $SUBJECT
		echo "Full run time of kernel-ci loop:"
		cat $KERNEL_CI_LOGTIME_FULL
		exit 1
	elif [[ -f $KERNEL_CI_OK_FILE ]]; then
		LOOP_COUNT=$(cat $KERNEL_CI_OK_FILE)
		SUBJECT="kernel-ci: fstests $FSTYPE never failed after $LOOP_COUNT test loops"
		echo $SUBJECT
		echo "Full run time of kernel-ci loop:"
		cat $KERNEL_CI_LOGTIME_FULL
		exit 0
	fi
fi

if [[ -f $KERNEL_CI_FAIL_FILE ]]; then
	FAIL_LOOP="$(cat $KERNEL_CI_FAIL_FILE)"
	SUBJECT="$SUBJECT_PREFIX $FAIL_LOOP"
	if [[ "$CONFIG_KERNEL_CI_EMAIL_METHOD_LOCAL" == "y" ]]; then
		cat $KERNEL_CI_DIFF_LOG | mail -s "$SUBJECT" $RCPT
	elif [[ "$CONFIG_KERNEL_CI_EMAIL_METHOD_SSH" == "y" ]]; then
		cat $KERNEL_CI_DIFF_LOG | ssh $SSH_TARGET 'mail -s "'$SUBJECT'"' $RCPT
	fi
	echo $SUBJECT
	exit 1
elif [[ -f $KERNEL_CI_OK_FILE ]]; then
	LOOP_COUNT=$(cat $KERNEL_CI_OK_FILE)
	SUBJECT="kernel-ci: fstests $FSTYPE never failed after $LOOP_COUNT test loops"
	if [[ "$CONFIG_KERNEL_CI_EMAIL_METHOD_LOCAL" == "y" ]]; then
		cat $KERNEL_CI_FAIL_LOG | mail -s "$SUBJECT" $RCPT
	elif [[ "$CONFIG_KERNEL_CI_EMAIL_METHOD_SSH" == "y" ]]; then
		cat $KERNEL_CI_FAIL_LOG | ssh $SSH_TARGET 'mail -s "'$SUBJECT'"' $RCPT
	fi
	echo "$SUBJECT"
	exit 0
else
	echo "Unexpected situation after full kernel-ci loop time:"
	cat $KERNEL_CI_LOGTIME_FULL
	exit 1
fi
