#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

COUNT=1

run_loop()
{
	while true; do
		echo "== kernel-ci blktests test loop $COUNT start: $(date)" > $KERNEL_CI_FAIL_LOG
		echo "/usr/bin/time -f %E make blktests-baseline" >> $KERNEL_CI_FAIL_LOG
		/usr/bin/time -p -o $KERNEL_CI_LOGTIME make blktests-baseline >> $KERNEL_CI_FAIL_LOG
		echo "End   $COUNT: $(date)" >> $KERNEL_CI_FAIL_LOG
		cat $KERNEL_CI_LOGTIME >> $KERNEL_CI_FAIL_LOG
		echo "git status:" >> $KERNEL_CI_FAIL_LOG
		git status >> $KERNEL_CI_FAIL_LOG
		echo "Results:" >> $KERNEL_CI_FAIL_LOG

		rm -f $KERNEL_CI_DIFF_LOG

		XUNIT_FAIL="no"
		if [ -f workflows/blktests/results/xunit_results.txt ]; then
			grep -q Failures workflows/blktests/results/xunit_results.txt
			if [[ $? -eq 0 ]]; then
				echo "Detected a failure as reported by xunit:" >> $KERNEL_CI_DIFF_LOG
				cat workflows/blktests/results/xunit_results.txt >> $KERNEL_CI_DIFF_LOG
				XUNIT_FAIL="yes"
			else
				echo "No failures detected by xunit:" >> $KERNEL_CI_DIFF_LOG
				cat workflows/blktests/results/xunit_results.txt >> $KERNEL_CI_FAIL_LOG
			fi
		fi

		DIFF_COUNT=$(git diff workflows/blktests/expunges/ | wc -l)
		if [[ "$DIFF_COUNT" -ne 0 ]]; then
			echo "Detected a failure as reported by differences in our expunge list" >> $KERNEL_CI_DIFF_LOG
		elif [[ "$XUNIT_FAIL" == "yes" ]]; then
			echo "" >> $KERNEL_CI_DIFF_LOG
			echo "Although xunit detects an error, no test bad file found. This is" >> $KERNEL_CI_DIFF_LOG
			echo "likely due to a test which xunit reports as failed causing a" >> $KERNEL_CI_DIFF_LOG
			echo "kernel warning." >> $KERNEL_CI_DIFF_LOG
			echo "" >> $KERNEL_CI_DIFF_LOG
		fi

		NEW_EXPUNGE_FILES="no"
		if [[ -f workflows/blktests/new_expunge_files.txt && "$(wc -l workflows/blktests/new_expunge_files.txt | awk '{print $1}')" -ne 0 ]]; then
			NEW_EXPUNGE_FILES="yes"
			echo "Detected a failure since new expunge files were found which are not commited into git" >> $KERNEL_CI_DIFF_LOG
			echo "New expunge file found, listing output below:" >> $KERNEL_CI_DIFF_LOG
			for i in $(cat workflows/blktests/new_expunge_files.txt); do
				echo "$i :"
				if [[ -f $i ]]; then
					cat $i >> $KERNEL_CI_DIFF_LOG
				else
					echo "Error: $i listed as new but its not found.." >> $KERNEL_CI_DIFF_LOG
				fi
			done
		fi

		if [[ "$DIFF_COUNT" -ne 0 || "$XUNIT_FAIL" == "yes" || "$NEW_EXPUNGE_FILES" == "yes" ]]; then
			echo "Test  $COUNT: FAILED!" >> $KERNEL_CI_DIFF_LOG
			echo "== Test loop count $COUNT" >> $KERNEL_CI_DIFF_LOG
			echo "$(git describe)" >> $KERNEL_CI_DIFF_LOG
			git diff >> $KERNEL_CI_DIFF_LOG
			cat $KERNEL_CI_DIFF_LOG >> $KERNEL_CI_FAIL_LOG
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
		if [[ "$CONFIG_KERNEL_CI_ENABLE_STEADY_STATE" == "y" &&
		      "$COUNT" -gt "$CONFIG_KERNEL_CI_STEADY_STATE_GOAL" ]]; then
			exit 0
		fi
		sleep 1
	done
}

rm -f $KERNEL_CI_FAIL_FILE $KERNEL_CI_OK_FILE
echo "= kernel-ci full log" > $KERNEL_CI_FULL_LOG
run_loop
