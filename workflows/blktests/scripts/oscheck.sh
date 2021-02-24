#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

# OS wrapper for blktests check.sh

OSCHECK_OSFILE_PREFIX=""
OSCHECK_SUBSYSTEM="blktests"

OS_FILE="/etc/os-release"
DRY_RUN="false"
EXPUNGE_FLAGS=""
ONLY_SHOW_CMD="false"
VERBOSE="false"
ONLY_TEST_GROUP=""
ONLY_CHECK_DEPS="false"
ONLY_QUESTION_DISTRO_KERNEL="false"
PRINT_START="false"
PRINT_DONE="false"

# Used to do a sanity check that the section we are running a test
# for has all intended files part of its expunge list. Updated per
# section run.
OSCHECK_EXCLUDE_DIR=""
EXPUNGE_TESTS=""
EXPUNGE_TESTS_COUNT=0

if [ ! -z "$OSCHECK_SUBSYSTEM" ]; then
	OSCHECK_OSFILE_PREFIX="_blktests"
fi

if [ -z "$OSCHECK_ONLY_RUN_DISTRO_KERNEL" ]; then
	OSCHECK_ONLY_RUN_DISTRO_KERNEL="false"
fi

if [ -z "$OSCHECK_CUSTOM_KERNEL" ]; then
	OSCHECK_CUSTOM_KERNEL="false"
fi

# Where we stuff the arguments we will pass to ./check
declare -a CHECK_ARGS

if [ -z "$OSCHECK_INCLUDE_PATH" ]; then
	OSCHECK_DIR="$(dirname $(readlink -f $0))"
	OSCHECK_INCLUDE_PATH="${OSCHECK_DIR}/../osfiles"
fi

if [ $(id -u) != "0" ]; then
	echo "Must run as root"
	exit 1
fi

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
	IDX=${#CHECK_ARGS[@]}
	CHECK_ARGS[$IDX]="$1"
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

if [ ! -z "$OSCHECK_OS_FILE" ]; then
	OS_FILE="$OSCHECK_OS_FILE"
fi

if [ -z "$OSCHECK_EXCLUDE_PREFIX" ]; then
	OSCHECK_EXCLUDE_PREFIX="$(dirname $(readlink -f $0))/../results/"
fi

# blktests check uses $ID for the test number, so we need to use something
# more unique. For example, on Debian this is "debian" for opensuse factory
# this is "opensuse" and for OpenSUSE Leap this is "opensuse-leap".
OSCHECK_ID=""
# VERSION_ID is 15.0 for OpenSUSE Leap 15.0, but Debian testing lacks VERSION_ID.
VERSION_ID=""

# Some distributions rely on things like lsb_release -r -s as the
# /etc/os-release file may not have a VERSION_ID annotated. So for
# instance OpenSUSE Leap uses /etc/os-release ID set to opensuse-leap
# and VERSION_ID="15.0" but Debian lacks such annotation on Debian
# testing. The OSCHECK_RELEASE can be used then by the osfile helpers.sh
# for distributions which want to support these releases.
export OSCHECK_RELEASE=""
which lsb_release 2>/dev/null 1>/dev/null
if [ $? -eq 0 ]; then
	export OSCHECK_RELEASE="$(lsb_release -r -s)"
fi

oscheck_include_os_files()
{
	if [ ! -e $OS_FILE ]; then
		return
	fi
	if [ -z $OSCHECK_ID ]; then
		return
	fi
	OSCHECK_INCLUDE_FILE="$OSCHECK_INCLUDE_PATH/$OSCHECK_ID/helpers.sh"
	test -s $OSCHECK_INCLUDE_FILE && . $OSCHECK_INCLUDE_FILE || true
	if [ ! -f $OSCHECK_INCLUDE_FILE ]; then
		echo "Your distribution lacks $OSCHECK_INCLUDE_FILE file ..."
	fi
}

os_has_osfile_read()
{
	if [ ! -e $OS_FILE ]; then
		return 1
	fi
	declare -f ${OSCHECK_ID}_read_osfile > /dev/null;
	return $?
}

oscheck_run_osfile_read()
{
	os_has_osfile_read $OSCHECK_ID
	if [ $? -eq 0 ] ; then
		${OSCHECK_ID}_read_osfile
	fi
}

oscheck_add_expunge_no_dups()
{
	echo $EXPUNGE_TESTS | grep -q "$1" 2>&1 > /dev/null
	if [[ $? -eq 0 ]]; then
		return 3
	fi

	EXPUNGE_FLAGS="$EXPUNGE_FLAGS -x ${1}"
	EXPUNGE_TESTS="$EXPUNGE_TESTS ${1}"
	let EXPUNGE_TESTS_COUNT=$EXPUNGE_TESTS_COUNT+1
	return 0
}


oscheck_add_expunge_if_exists_no_dups()
{
	if [[ ! -e tests/$1 ]]; then
		return 1
	fi
	oscheck_add_expunge_no_dups $1
	return $?
}

os_has_special_expunges()
{
	if [ ! -e $OS_FILE ]; then
		return 1
	fi
	declare -f ${OSCHECK_ID}${OSCHECK_OSFILE_PREFIX}_special_expunges > /dev/null;
	return $?
}

oscheck_handle_special_expunges()
{
	os_has_special_expunges $OSCHECK_ID
	if [ $? -eq 0 ] ; then
		${OSCHECK_ID}${OSCHECK_OSFILE_PREFIX}_special_expunges
	fi
}

oscheck_get_group_files()
{
	if [ "$EXPUNGE_LIST" = "true" ]; then
		echo "Looking for files which we should expunge in directory $BLOCK_EXCLUDE_DIR ..."
	fi
	if [[ ! -d $BLOCK_EXCLUDE_DIR ]]; then
		return
	fi
	BAD_FILES=$(find $BLOCK_EXCLUDE_DIR -type f \( -iname \*.bad -o -iname \*.dmesg \) | sed -e 's|'$BLOCK_EXCLUDE_DIR'||')
	for i in $BAD_FILES; do
		COLS=$(echo $i | awk -F"/" '{print NF}')
		if [[ $COLS -ne 3 ]]; then
			continue
		fi

		BDEV=$(echo $i | awk -F"/" '{print $1}')
		GROUP=$(echo $i | awk -F"/" '{print $2}')
		BADFILE=$(echo $i | awk -F"/" '{print $3}')

		if [[ "$RUN_GROUP" != "" ]]; then
			if [[ "$GROUP" != "$RUN_GROUP" ]]; then
				continue
			fi
		fi
		COLS=$(echo $BADFILE | awk -F"." '{print NF}')
		if [[ $COLS -lt 2 ]]; then
			continue
		fi
		NUMBER=$(echo $BADFILE | awk -F"." '{print $1}')
		ENTRY="$GROUP/$NUMBER"
		oscheck_add_expunge_if_exists_no_dups $ENTRY
		if [[ $? -eq 1 && "$EXPUNGE_LIST" = "true" ]]; then
			echo "$ENTRY is not a test present on your version of blktests"
		fi
	done
	OSCHECK_EXPUNGE_FILE="$(dirname $(readlink -f $0))/../expunges/$(uname -r)/failures.txt"
	if [[ "$EXPUNGE_LIST" = "true" ]]; then
		echo "Looking to see if $OSCHECK_EXPUNGE_FILE exists and has any entries we may have missed ..."
	fi
	if [[ -f $OSCHECK_EXPUNGE_FILE ]]; then
		if [[ "$EXPUNGE_LIST" = "true" ]]; then
			echo "$OSCHECK_EXPUNGE_FILE exists, processing its expunges ..."
		fi
		BAD_EXPUNGES=$(cat $OSCHECK_EXPUNGE_FILE| awk '{print $1}')
		for i in $BAD_EXPUNGES; do
			oscheck_add_expunge_no_dups $i
		done
	fi
}

oscheck_count_check()
{
	if [[ "$EXPUNGE_TESTS_COUNT" -eq 0 ]]; then
		if [[ "$RUN_GROUP" != "" ]]; then
			echo "No expunges for blktests on test group $GROUP -- a perfect kernel!"
		else
			echo "No expunges for blktests -- a perfect kernel!"
		fi
	fi
}

oscheck_handle_group_expunges()
{
	EXPUNGE_FLAGS=""
	if [ "$EXPUNGE_LIST" = "true" ]; then
		if [[ "$RUN_GROUP" != "" ]]; then
			echo "List of blktests expunges for group $GROUP:"
		else
			echo "List of blktests expunges:"
		fi
	fi

	oscheck_handle_special_expunges

	if [ -e $OS_FILE ]; then
		BLOCK_EXCLUDE_DIR="${OSCHECK_EXCLUDE_PREFIX}/${OSCHECK_ID}/${VERSION_ID}/"
		OSCHECK_EXCLUDE_DIR="$BLOCK_EXCLUDE_DIR"
		if [ "$OSCHECK_CUSTOM_KERNEL" == "true" ]; then
			if [ "$OSCHECK_ONLY_RUN_DISTRO_KERNEL" != "true" ]; then
				BLOCK_EXCLUDE_DIR="${OSCHECK_EXCLUDE_PREFIX}/$(uname -r)/"
				OSCHECK_EXCLUDE_DIR="$BLOCK_EXCLUDE_DIR"
			fi
		fi
		oscheck_get_group_files
	fi

	# One more check for distro agnostic expunges. Right now this is just an
	# informal group listing. Only files named after a section would be treated
	# as generic expunges for blktests, but as of right now we have none.
	BLOCK_EXCLUDE_DIR="${OSCHECK_EXCLUDE_PREFIX}/any/"
	# Don't update OSCHECK_EXCLUDE_DIR as these are extra files only.
	oscheck_get_group_files
}

oscheck_run_cmd()
{
	if [ "$ONLY_SHOW_CMD" = "false" ]; then
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

	oscheck_handle_group_expunges
	oscheck_count_check
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

# If you don't have the /etc/os-release we try to use lsb_release
oscheck_read_osfile_and_includes()
{
	if [ -e $OS_FILE ]; then
		eval $(grep '^ID=' $OS_FILE)
		export OSCHECK_ID="$ID"
		oscheck_include_os_files
		oscheck_run_osfile_read
	else
		which lsb_release 2>/dev/null
		if [ $? -eq 0 ]; then
			export OSCHECK_ID="$(lsb_release -i -s | tr '[A-Z]' '[a-z]')"
			oscheck_include_os_files
			oscheck_run_osfile_read
		fi
	fi
}

os_has_distro_kernel_check_handle()
{
	if [ ! -e $OS_FILE ]; then
		return 1
	fi
	declare -f ${OSCHECK_ID}_distro_kernel_check > /dev/null;
	return $?
}

oscheck_distro_kernel_check()
{
	os_has_distro_kernel_check_handle
	if [ $? -eq 0 ] ; then
		${OSCHECK_ID}_distro_kernel_check
		if [ $? -ne 0 ] ; then
			OSCHECK_CUSTOM_KERNEL="true"
			if [ "$ONLY_QUESTION_DISTRO_KERNEL" = "true" ]; then
				echo "You are not running a distribution packaged kernel:"
				uname -a
				exit 1
			fi
			if [ "$OSCHECK_ONLY_RUN_DISTRO_KERNEL" == "true" ]; then
				echo "Not running a distro kernel, skipping..."
				echo "If you want to run this test disable:"
				echo "OSCHECK_ONLY_RUN_DISTRO_KERNEL"
				exit 1
			fi
			echo "Running custom kernel: $(uname -a)"
		else
			if [ "$ONLY_QUESTION_DISTRO_KERNEL" = "true" ]; then
				echo "Running distro kernel"
				uname -a
				exit 0
			fi
		fi
	fi
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

oscheck_read_osfile_and_includes
oscheck_distro_kernel_check

RUN_GROUP=""
if [ "$ONLY_TEST_GROUP" != "" ]; then
	RUN_GROUP="$ONLY_TEST_GROUP"
	echo "Only testing group: $ONLY_TEST_GROUP"
fi

check_check
CHECK_RET=$?
if [ $CHECK_RET -ne 0 ]; then
	exit $CHECK_RET
fi

tmp=/tmp/$$
trap "_cleanup; exit \$status" 0 1 2 3 15

oscheck_run_groups
