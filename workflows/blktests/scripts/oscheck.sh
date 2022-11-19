#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

# OS wrapper for blktests check.sh

DRY_RUN="false"
ONLY_SHOW_CMD="false"
VERBOSE="false"
ONLY_TEST_GROUP=""
ONLY_CHECK_DEPS="false"
PRINT_START="false"
PRINT_DONE="false"

# Where we stuff the arguments we will pass to ./check
declare -a CHECK_ARGS

if [ $(id -u) != "0" ]; then
	echo "Must run as root"
	exit 1
fi

OSCHECK_DIR="$(dirname $(readlink -f $0))"
OSCHECK_LIB="$OSCHECK_DIR/oscheck-lib.sh"
if [ ! -f $OSCHECK_LIB ]; then
	echo "Missing oscheck library: $OSCHECK_LIB"
	exit 1
fi
source $OSCHECK_LIB
oscheck_lib_init_vars

oscheck_usage()
{
	echo "$0 - wrapper for blktests check.sh for different Operating Systems"
	echo "--help          - Shows this menu"
	echo "--show-cmd      - Only show the check.sh we'd execute, do not run it"
	echo "--expunge-list  - List all files we look as possible expunge files, works as if --show-cmd was used as well"
	echo "--test-group <group> - Only run the tests for the specified group"
	echo "--is-distro     - Only checks if the kernel detected is a distro kernel or not, does not run any tests"
	echo "--custom-kernel - Only checks if the kernel detected is a distro kernel or not, does not run any tests"
	echo "--print-start   - Echo into /dev/kmsg when we've started with run blktests blktestsstart/000 at time'"
	echo "--print-done    - Echo into /dev/kmsg when we're done with run blktests blktestsdone/000 at time'"
	echo "--verbose       - Be verbose when debugging"
	echo ""
	echo "Note that all parameters which we do not understand we'll just"
	echo "pass long to check.sh so it can use them. So calling oscheck.sh -g quick"
	echo "will call check.sh -g quick."
}

copy_to_check_arg()
{
	CHECK_ARGS+=" $1"
}

parse_args()
{
	while [[ ${#1} -gt 0 ]]; do
		key="$1"

		case $key in
		--show-cmd)
			ONLY_SHOW_CMD="true"
			shift
			;;
		--expunge-list)
			EXPUNGE_LIST="true"
			ONLY_SHOW_CMD="true"
			shift
			;;
		--test-group)
			ONLY_TEST_GROUP="$2"
			shift
			shift
			;;
		--verbose)
			VERBOSE="true"
			shift
			;;
		--is-distro)
			ONLY_QUESTION_DISTRO_KERNEL="true"
			shift
			;;
		--custom-kernel)
			OSCHECK_CUSTOM_KERNEL="true"
			shift
			;;
		--help)
			oscheck_usage
			exit
			;;
		--print-start)
			PRINT_START="true"
			shift
			;;
		--print-done)
			PRINT_DONE="true"
			shift
			;;
		*)
			copy_to_check_arg $key
			shift
			;;
		esac
	done
}

parse_args $@

oscheck_run_cmd()
{
	if [ "$ONLY_SHOW_CMD" = "false" ]; then
		echo "LC_ALL=C $OSCHECK_CMD" /tmp/run-cmd.txt
		LC_ALL=C $OSCHECK_CMD
	else
		echo "LC_ALL=C $OSCHECK_CMD"
	fi
}

oscheck_run_groups()
{
	if [[ "$PRINT_START" == "true" ]]; then
		NOW=$(date --rfc-3339='seconds' | awk -F"+" '{print $1}')
		echo "run blktests blktestsstart/000 at $NOW" > /dev/kmsg
	fi

	OSCHECK_CMD="./check ${RUN_GROUP} $EXPUNGE_FLAGS ${CHECK_ARGS[@]}"
	oscheck_run_cmd

	if [[ "$PRINT_DONE" == "true" ]]; then
		NOW=$(date --rfc-3339='seconds' | awk -F"+" '{print $1}')
		echo "run blktests blktestsdone/000 at $NOW" > /dev/kmsg
	fi
}

_cleanup() {
	echo "Done"
}

check_check()
{
	if [ ! -e ./check ]; then
		echo "Must run within blktests tree, assuming you are just setting up"
		echo "Bailing. Keep running this until all requirements are met above"
		return 1
	fi
	return 0
}

oscheck_lib_read_osfiles_verify_kernel
oscheck_lib_set_run_group $ONLY_TEST_GROUP

check_check
CHECK_RET=$?
if [ $CHECK_RET -ne 0 ]; then
	exit $CHECK_RET
fi

tmp=/tmp/$$
trap "_cleanup; exit \$status" 0 1 2 3 15

oscheck_lib_set_expunges
oscheck_run_groups
