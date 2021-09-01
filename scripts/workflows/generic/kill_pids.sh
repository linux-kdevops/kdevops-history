# SPDX-License-Identifier: copyleft-next-0.3.1
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

STRING='IGNORE'
FS=""
TARGET_WORFKLOW=""
WATCHDOG_MODE="False"

usage()
{
	echo "$0 - lists / kills workflow processes"
	echo "--help          - Shows this menu"
	echo "--watchdog-mode - To be used if running from within the watchdog"
}

parse_args()
{
	while [[ ${#1} -gt 0 ]]; do
		key="$1"

		case $key in
		--watchdog-mode)
			WATCHDOG_MODE="true"
			shift
			;;
		--help)
			usage
			exit
			;;
		*)
			usage
			exit
			;;
		esac
	done
}

parse_args $@

if [[ "$CONFIG_KDEVOPS_WORKFLOW_ENABLE_FSTESTS" == "y" ]]; then
	FS=$CONFIG_FSTESTS_FSTYP
	STRING='CONFIG_FSTESTS_FSTYP='
	TARGET_WORFKLOW="fstests"
elif [[ "$CONFIG_KDEVOPS_WORKFLOW_ENABLE_BLKTESTS" == "y" ]]; then
	STRING='CONFIG_KDEVOPS_WORKFLOW_ENABLE_BLKTESTS=y'
	TARGET_WORFKLOW="blktests"
elif [[ "$CONFIG_WORKFLOWS_REBOOT_LIMIT" == "y" ]]; then
	STRING='CONFIG_WORKFLOWS_REBOOT_LIMIT=y'
	TARGET_WORFKLOW="reboot-limit"
else
	echo "Unsupported currently configured target workflow"
	exit
fi

PID_LIST=$(ps -fu $USER | awk '{print $2}')

if [[ "$LIST_ONLY" != "true" ]]; then
	# On a manually called kill we want to avoid spamming folks.
	if [[ "$WATCHDOG_MODE" != "true" ]]; then
		touch $MANUAL_KILL_NOTICE_FILE
	fi
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
	if [[ "$CONFIG_KDEVOPS_WORKFLOW_ENABLE_FSTESTS" == "y" ]]; then
		FS_TARGET=$(grep $STRING $CONFIG_TARGET | awk -F"=" '{print $2}' | sed -e 's|"||g')
		if [[ "$FS" != "$FS_TARGET" ]]; then
			continue
		fi
	elif [[ "$CONFIG_KDEVOPS_WORKFLOW_ENABLE_BLKTESTS" == "y" ]]; then
		grep -q $STRING $CONFIG_TARGET
		if [[ $? -ne 0 ]]; then
			continue
		fi
	fi

	grep -q run_kernel_ci /proc/$i/cmdline
	if [[ $? -eq 0 ]]; then
		if [[ "$LIST_ONLY" == "true" ]]; then
			list_pid $i skip
			continue
		fi
		continue
	fi

	grep -q "${TARGET_WORFKLOW}-baseline-loop" /proc/$i/cmdline
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
