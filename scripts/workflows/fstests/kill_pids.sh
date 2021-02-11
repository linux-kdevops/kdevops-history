# SPDX-License-Identifier: GPL-2.0
if [[ "${TOPDIR}" == "" ]]; then
	TOPDIR=$PWD
fi
source ${TOPDIR}/.config
source ${TOPDIR}/scripts/lib.sh

CALL=$(basename $0)
LIST_ONLY="False"

if [[ "$CALL" == "list_pids.sh" ]]; then
	LIST_ONLY="true"
fi

FS=$CONFIG_FSTESTS_FSTYP
STRING='CONFIG_FSTESTS_FSTYP='
PID_LIST=$(ps -fu $USER | awk '{print $2}')

if [[ "$LIST_ONLY" != "true" ]]; then
	touch $MANUAL_KILL_NOTICE_FILE
fi

list_pid()
{
	if [[ "$2" == "kill" ]]; then
		echo "Would be killed:"
	elif [[ "$2" == "skip" ]]; then
		echo "Would be skipped:"
	fi
	cat /proc/$1/cmdline
	echo
}

for i in $PID_LIST; do
	if [[ ! -d /proc/$i ]]; then
		continue
	fi
	CONFIG_TARGET="/proc/$i/cwd/.config"
	if [[ ! -f  $CONFIG_TARGET ]]; then
		continue
	fi
	FS_TARGET=$(grep $STRING $CONFIG_TARGET | awk -F"=" '{print $2}' | sed -e 's|"||g')
	if [[ "$FS" != "$FS_TARGET" ]]; then
		continue
	fi

	grep -q run_kernel_ci /proc/$i/cmdline
	if [[ $? -eq 0 ]]; then
		if [[ "$LIST_ONLY" == "true" ]]; then
			list_pid $i skip
			continue
		fi
		continue
	fi

	grep -q "fstests-baseline-loop" /proc/$i/cmdline
	if [[ $? -eq 0 ]]; then
		if [[ "$LIST_ONLY" == "true" ]]; then
			list_pid $i skip
			continue
		fi
		continue
	fi

	grep -q make /proc/$i/cmdline
	if [[ $? -eq 0 ]]; then
		if [[ "$LIST_ONLY" == "true" ]]; then
			list_pid $i skip
			echo "Would be killed:"
			cat /proc/$i/cmdline
			echo
			continue
		fi
		kill -SIGTERM -- -${i} 2>/dev/null
		kill -SIGTERM ${i} 2>/dev/null
	fi

	grep -q run_loop /proc/$i/cmdline
	if [[ $? -eq 0 ]]; then
		if [[ "$LIST_ONLY" == "true" ]]; then
			list_pid $i kill
			continue
		fi
		kill -SIGTERM -- -${i} 2>/dev/null
		kill -SIGTERM ${i} 2>/dev/null
	fi

	grep -q ansible-playbook /proc/$i/cmdline
	if [[ $? -eq 0 ]]; then
		if [[ "$LIST_ONLY" == "true" ]]; then
			list_pid $i kill
			continue
		fi
		kill -SIGTERM -- -${i} 2>/dev/null
		kill -SIGALRM -- -${i} 2>/dev/null
		kill -SIGALRM ${i} 2>/dev/null
		continue
	fi

	grep -q ssh /proc/$i/cmdline
	if [[ $? -eq 0 ]]; then
		if [[ "$LIST_ONLY" == "true" ]]; then
			list_pid $i kill
			continue
		fi
		kill -SIGTERM -- -${i} 2>/dev/null
		kill -SIGTERM ${i} 2>/dev/null
	fi
done

if [[ "$LIST_ONLY" != "true" ]]; then
	rm -f $MANUAL_KILL_NOTICE_FILE
fi
