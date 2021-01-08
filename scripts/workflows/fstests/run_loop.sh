#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

FSTYPE="$CONFIG_FSTESTS_FSTYP"
COUNT=1

run_loop()
{
	while true; do
		echo "== kernel-ci fstests $FSTYPE test loop $COUNT start: $(date)" > $KERNEL_CI_FAIL_LOG
		echo "/usr/bin/time -f %E make fstests-baseline" >> $KERNEL_CI_FAIL_LOG
		/usr/bin/time -p -o $KERNEL_CI_LOGTIME make fstests-baseline >> $KERNEL_CI_FAIL_LOG
		echo "End   $COUNT: $(date)" >> $KERNEL_CI_FAIL_LOG
		cat $KERNEL_CI_LOGTIME >> $KERNEL_CI_FAIL_LOG
		echo "git status:" >> $KERNEL_CI_FAIL_LOG
		git status >> $KERNEL_CI_FAIL_LOG
		echo "Results:" >> $KERNEL_CI_FAIL_LOG
		XUNIT_FAIL="no"
		if [ -f workflows/fstests/results/xunit_results.txt ]; then
			cat workflows/fstests/results/xunit_results.txt >> $KERNEL_CI_FAIL_LOG
			grep -q Failures workflows/fstests/results/xunit_results.txt
			if [[ $? -eq 0 ]]; then
				echo "Detected a failure as reportd by xunit" >> $KERNEL_CI_FAIL_LOG
				XUNIT_FAIL="yes"
			fi
		fi
		DIFF_COUNT=$(git diff workflows/fstests/expunges/ | wc -l)
		if [[ "$DIFF_COUNT" -ne 0 || $XUNIT_FAIL=="yes" ]]; then
			echo "Test  $COUNT: FAILED!" >> $KERNEL_CI_FAIL_LOG
			echo "Detected a failure as reported by differences in our expunge list" >> $KERNEL_CI_FAIL_LOG
			echo "== Test loop count $COUNT" >> $KERNEL_CI_FAIL_LOG
			echo "$(git describe)" >> $KERNEL_CI_FAIL_LOG
			git diff >> $KERNEL_CI_FAIL_LOG
			cat $KERNEL_CI_FAIL_LOG >> $KERNEL_CI_FULL_LOG
			echo $COUNT > $KERNEL_CI_FAIL_FILE
			exit 1
		else
			echo "Test  $COUNT: OK!" >> $KERNEL_CI_FAIL_LOG
			echo "----------------------------------------------------------------" >> $KERNEL_CI_FAIL_LOG
			cat $KERNEL_CI_FAIL_LOG >> $KERNEL_CI_FULL_LOG
		fi
		echo $COUNT > $KERNEL_CI_OK_FILE
		let COUNT=$COUNT+1
		sleep 1
	done
}

rm -f $KERNEL_CI_FAIL_FILE $KERNEL_CI_OK_FILE
echo "= kernel-ci full log" > $KERNEL_CI_FULL_LOG
run_loop
