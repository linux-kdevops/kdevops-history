#!/bin/bash
# OS wrapper for check.sh

DRY_RUN="false"
ONLY_SHOW_CMD="false"
VERBOSE="false"
TEST_ARG_SECTION=""
ONLY_CHECK_DEPS="false"
PRINT_START="false"
PRINT_DONE="false"

# Stuff we use for mkfs. check.sh assumes a few things so we try to
# do our best.
TEST_DEV=""
TEST_DIR=""
MOUNT_OPTIONS=""
TEST_FS_MOUNT_OPTS=""
MKFS_OPTIONS=""
SCRATCH_DEV_POOL=""

# For sanity checks before we run, we should remove this as ansible
# should do these checks for us.
REQS="gcc"
REQS="$REQS git"
REQS="$REQS make"
REQS="$REQS automake"
REQS="$REQS gawk"
REQS="$REQS chattr"
REQS="$REQS fio"
REQS="$REQS setcap"
REQS="$REQS setfattr"

if [ "$FSTYP" = "xfs" ] ; then
	REQS="$REQS xfs_info"
fi

# Ansible should check this for us too.
USERS_NEEDED="fsgqa"

GROUPS_NEEDED="fsgqa"
GROUPS_NEEDED="$GROUPS_NEEDED sys"

DIRS_NEEDED="/home/fsgqa"
DIRS_NEEDED="$DIRS_NEEDED /media/test"
DIRS_NEEDED="$DIRS_NEEDED /media/scratch/"

# We keep two versions, one the actual version spit out by the program,
# the others as interreted by linux/scripts/ld-version.sh as it is simple
# and tested over time. It also allows easy requirements to be checked for
# using simple math.
#
# For instance:
#
# $ echo 4.15.1 | ~/linux-next/scripts/ld-version.sh
# 415010000
# The VERSION would be 4.15.1 while the LD_VERSION would be 415010000
XFSPROGS_VERSION=""
XFSPROGS_LD_VERSION=""
# -m option added as of xfsprogs 3.2.0 via commit f7b8029124db6
# ("xfsprogs: introduce CRC support into mkfs.xfs")
XFSPROGS_LD_VERSION_M="302000000"

BTRFSPROGS_VERSION=""
BTRFSPROGS_LD_VERSION=""

E2FSPROGS_VERSION=""
E2FSPROGS_LD_VERSION=""

REISERFS_PROGS_VERSION=""
REISERFS_PROGS_LD_VERSION=""

SKIP_GROUPS=

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
	echo "$0 - wrapper for fstests check.sh for different Operating Systems"
	echo "--help          - Shows this menu"
	echo "-n              - Triggers check.sh to also run with -n, a dry run"
	echo "--show-cmd      - Only show the check.sh we'd execute, do not run it, must run with -n"
	echo "--expunge-list  - List all files we look as possible expunge files, must run with -n, works as if --show-cmd was used as well"
	echo "--test-section <section> - Only run the tests for the specified section"
	echo "--check-deps    - Only check for fstests build dependencies"
	echo "--is-distro     - Only checks if the kernel detected is a distro kernel or not, does not run any tests"
	echo "--custom-kernel - Only checks if the kernel detected is a distro kernel or not, does not run any tests"
	echo "--fast-tests    - Run oscheck's interpretation of what fast test are"
	echo "--large-disk    - Include tests that require a large disk"
	echo "--print-start   - Echo into /dev/kmsg when we've started with run fstests fstestsstart/000 at time'"
	echo "--print-done    - Echo into /dev/kmsg when we're done with run fstests fstestsdone/000 at time'"
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
		-n)
			echo "Dry run"
			DRY_RUN="true"
			copy_to_check_arg $key
			shift
			;;
		--show-cmd)
			ONLY_SHOW_CMD="true"
			shift
			;;
		--expunge-list)
			EXPUNGE_LIST="true"
			ONLY_SHOW_CMD="true"
			shift
			;;
		--test-section)
			TEST_ARG_SECTION="$2"
			shift
			shift
			;;
		--check-deps)
			ONLY_CHECK_DEPS="true"
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
		--fast-tests)
			FAST_TEST="y"
			shift
			;;
		--large-disk)
			FSTESTS_RUN_LARGE_DISK_TESTS="y"
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

# Gets your respective filesystem program version. Expand as more
# filesystems are supported.
oscheck_get_progs_version()
{
	case "$FSTYP" in
	"xfs")
		XFSPROGS_VERSION="$(mkfs.xfs -V | awk '{print $3}')"
		XFSPROGS_LD_VERSION="$(echo $XFSPROGS_VERSION | ${OSCHECK_DIR}/ld-version.sh)"
		;;
	"btrfs")
		BTRFSPROGS_VERSION="$(mkfs.btrfs -V | awk '{print $5}')"
		BTRFSPROGS_LD_VERSION="$(echo $BTRFSPROGS_VERSION | ${OSCHECK_DIR}/ld-version.sh)"
		;;
	"ext4" | "ext3" | "ext2")
		E2FSPROGS_VERSION="$(mkfs.ext4 -V 2>&1 | head -1 | awk '{print $2}')"
		E2FSPROGS_LD_VERSION="$(echo $E2FSPROGS_VERSION | ${OSCHECK_DIR}/ld-version.sh)"
		;;
	"reiserfs")
		REISERFS_PROGS_VERSION="$(mkfs.reiserfs -V 2>&1 | head -1 | awk '{print $2}')"
		REISERFS_PROGS_LD_VERSION="$(echo $REISERFS_PROGS_VERSION | ${OSCHECK_DIR}/ld-version.sh)"
		;;
	*)
		if [ "$VERBOSE" = "true" ]; then
			echo "Not collecting progs version for filesystem: $FSTYP"
		fi
		;;
	esac
}

req_install_possible()
{
	declare -f ${OSCHECK_ID}_install_${1} > /dev/null;
	return $?
}

service_restart_possible()
{
	declare -f ${OSCHECK_ID}_restart_${1} > /dev/null;
	return $?
}

service_restart()
{
	service_restart_possible $1
	if [ $? -eq 0 ] ; then
		${OSCHECK_ID}_restart_${1}
	fi
}

# fstests uses this to check if it should be using NIS for looking for a
# username, ie _require_user() calls _cat_passwd() and that in turn uses ypcat
# passwd if _yp_active() returns 0. _yp_active() returns 0 when domainname is
# not empty, (none) or localdomain.  This logic seems debatably flawed as
# otherwise we end up with plenty of false positives. However addressing this
# requires an upstream discussion.  In the meantime deal with this as a service
# quirk. If you're tired of seeing this fail consider setting
# FSTESTS_SETUP_SYSTEM and ensure you have a proper
# ${OSCHECK_ID}_restart_ypbind() defined for your OS.
_yp_active()
{
	local dn
	dn=$(domainname 2>/dev/null)
	test -n "${dn}" -a "${dn}" != "(none)" -a "${dn}" != "localdomain"
	return $?
}

check_services()
{
	RET=0
	_yp_active > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		 ypcat passwd > /dev/null 2>&1
		 if [ $? -ne 0 ] ; then
			if [ "$FSTESTS_SETUP_SYSTEM" = "y" ]; then
				service_restart ypbind
				ypcat passwd > /dev/null 2>&1
				if [ $? -ne 0 ] ; then
					echo "Tried restarting ypbind service but that did not work to get 'ypcat passwd' working."
					RET=1
				fi
			else
				echo -n "Connection to NIS server is down."
				echo -n "As per fstests ypbind service must be available as your domainname is set: $(domainname)"
				RET=1
			fi
		 fi
	fi
	return $RET
}

check_reqs()
{
	R=0
	if [ "$DRY_RUN" = "true" ]; then
		return
	fi

	for g in $GROUPS_NEEDED; do
		if ! getent group $g > /dev/null 2>&1; then
			echo "ERROR: group $g is required for complete testing." >&2
			if [ "$FSTESTS_SETUP_SYSTEM" = "y" ]; then
				groupadd $g
			fi
			R=1
		fi
	done

	for u in $USERS_NEEDED; do
		if ! getent passwd $u > /dev/null 2>&1; then
			echo "ERROR: user $u is required for complete testing." >&2
			if [ "$FSTESTS_SETUP_SYSTEM" = "y" ]; then
				USE_GROUP=""
				if [ "$u" = "fsgqa" ]; then
					USE_GROUP="-g fsgqa"
				fi
				useradd $u $USE_GROUP
			fi
			R=1
		fi
	done

	# As per required by xfs/106
	CURRENT_FSGQA_GROUP=$(id -g fsgqa)
	FSGQA_GROUP_ID=$(getent group fsgqa | awk -F":" '{print $3}')
	if [ "$CURRENT_FSGQA_GROUP" != "$FSGQA_GROUP_ID" ]; then
		echo "ERROR: user fsgqa must have primary group fsgqa" >&2
		if [ "$FSTESTS_SETUP_SYSTEM" = "y" ]; then
			usermod -g fsgqa fsgqa
		fi
	fi

	for dir in $DIRS_NEEDED; do
		if [ ! -d $dir ]; then
			mkdir -p $dir
		fi
	done

	for req in $REQS; do
		if ! which $req > /dev/null 2>&1 ; then
			echo "ERROR: $req is required for complete testing." >&2
			R=1
		fi
	done

	check_services
	if [ $? -ne 0 ]; then
		R=1
	fi
	return $R
}

check_mount()
{
	for mount_dir in $(awk '{print $2}' /proc/mounts); do
		if [ "$mount_dir" = "$1" ]; then
			return 0
		fi
	done
	return 1
}

# osfiles helpers can use this common generic helper
oscheck_systemctl_restart_ypbind()
{
	which ypbind 2>/dev/null
	if [ $? -ne 0 ]; then
		return
	fi

	systemctl is-enabled --quiet ypbind.service 2> /dev/null
	if [ $? -eq 0 ]; then
		echo "Restarting ypbind.service..."
		systemctl restart ypbind.service
	fi
}

os_has_group_handle()
{
	if [ ! -e $OS_FILE ]; then
		return 1
	fi
	declare -f ${OSCHECK_ID}_skip_groups > /dev/null;
	return $?
}

oscheck_handle_skipping_group()
{
	os_has_group_handle
	if [ $? -eq 0 ] ; then
		${OSCHECK_ID}_skip_groups
	fi
}

os_has_section_handle()
{
	if [ ! -e $OS_FILE ]; then
		return 1
	fi
	declare -f ${OSCHECK_ID}_queue_sections > /dev/null;
	return $?
}

oscheck_queue_sections()
{
	os_has_section_handle
	if [ $? -eq 0 ] ; then
		${OSCHECK_ID}_queue_sections
	fi
}

oscheck_run_cmd()
{
	if [ "$ONLY_SHOW_CMD" = "false" ]; then
		echo "LC_ALL=C bash $OSCHECK_CMD" > /tmp/run-cmd.txt
		LC_ALL=C bash $OSCHECK_CMD
	else
		echo "LC_ALL=C bash $OSCHECK_CMD"
	fi
}

oscheck_run_section()
{
	SECTION=$RUN_SECTION
	if [[ "$LIMIT_TESTS" == "" ]]; then
		oscheck_count_check
	fi
	SECTION_ARGS=

	if [ "$SECTION" != "all" ]; then
		SECTION_ARGS="-s $SECTION"
	fi

	# Need to do this as RUN_SECTION is used inside of ./check to determine which section to run
	unset RUN_SECTION

	if [[ "$PRINT_START" == "true" ]]; then
		NOW=$(date --rfc-3339='seconds' | awk -F"+" '{print $1}')
		echo "run fstests fstestsstart/000 at $NOW" > /dev/kmsg
	fi

	OSCHECK_CMD="./check $SECTION_ARGS -R xunit $_RUN_GROUPS $_SKIP_GROUPS $EXPUNGE_FLAGS $CHECK_ARGS"
	oscheck_run_cmd
	if [[ "$PRINT_DONE" == "true" ]]; then
		NOW=$(date --rfc-3339='seconds' | awk -F"+" '{print $1}')
		echo "run fstests fstestsdone/000 at $NOW" > /dev/kmsg
	fi
}

_check_dev_setup()
{
	mkdir -p $TEST_DIR

	# Nothing to be done for NFS
	if [ "$FSTYP" = "nfs" ]; then
		return
	fi

	blkid -t TYPE=$FSTYP $TEST_DEV /dev/null
	if [[ $? -ne 0 ]]; then
		echo "FSTYP: $FSTYP Section: $INFER_SECTION with TEST_DEV: $TEST_DEV and MKFS_OPTIONS: $MKFS_OPTIONS TEST_DIR: $TEST_DIR"
		CMD="mkfs.$FSTYP $MKFS_OPTIONS $TEST_DEV"
		echo "$CMD"
		$CMD
	fi

	check_mount $TEST_DIR
	if [ $? -ne 0 ]; then
		OSCHECK_MOUNT_CMD="mount $TEST_OPTIONS $TEST_FS_MOUNT_OPTS $SELINUX_MOUNT_OPTIONS  $TEST_DEV $TEST_DIR"
		echo "$(basename $0) initial mount for $TEST_DIR using:"
		echo $OSCHECK_MOUNT_CMD
		$OSCHECK_MOUNT_CMD
		umount $TEST_DIR
	fi
}

oscheck_test_dev_setup()
{
	if [ "$DRY_RUN" = "true" ]; then
		return
	fi

	if [ "$RUN_SECTION" = "all" ]; then
		for i in $(oscheck_lib_all_fs_sections)
		do
			echo "checking section $i"
			oscheck_lib_parse_config_section $i
			_check_dev_setup
		done
		return
	fi
	_check_dev_setup
}

_cleanup() {
	echo "Done"
}

check_check()
{
	if [ ! -e ./check ]; then
		echo "Must run within fstests tree, assuming you are just setting up"
		echo "Bailing. Keep running this until all requirements are met above"
		return 1
	fi
	return 0
}

check_kernel_config()
{
	CONFIG_RET=0
	if [ -e /proc/config.gz ]; then
		for opt in CONFIG_DM_FLAKEY CONFIG_FAULT_INJECTION CONFIG_FAULT_INJECTION_DEBUG_FS; do
			if ! zgrep -q "${opt}=" /proc/config.gz; then
				CONFIG_RET=1
				echo "WARNING: ${opt} is required for testing i/o failures." >&2
			fi
		done
	fi
	return $CONFIG_RET
}

check_test_dev_setup()
{
	DEV_SETUP_RET=0
	if [ "$DRY_RUN" = "true" ]; then
		return
	fi

	# FIXME: check server for reachability?
	if [ "$FSTYP" = "nfs" ]; then
		return
	fi

	if [ "$RUN_SECTION" = "all" ]; then
		for i in $(oscheck_lib_all_fs_sections)
		do
			echo "checking section $i"
			oscheck_lib_parse_config_section $i
			if [[ ! -e $TEST_DEV ]]; then
				echo "$TEST_DEV is not present"
				return 1
			fi
		done
		return
	fi

	if [[ ! -e $TEST_DEV ]]; then
		echo "$TEST_DEV is not present"
		DEV_SETUP_RET=1
	fi
	return $DEV_SETUP_RET
}

check_dev_pool()
{
	DEV_POOL_RET=0

	if [ "$FSTYP" = "nfs" ]; then
		return 0
	fi

	# If we have a specific setup and don't specify SCRATCH_DEV_POOL just
	# ignore this particular check.
	if [ "$SCRATCH_DEV_POOL" == "" ]; then
		return 0;
	fi
	if [ -e $HOST_OPTIONS ]; then
		NDEVS=$(echo $SCRATCH_DEV_POOL|wc -w)
		if [ "$NDEVS" -lt 5 ]; then
			DEV_POOL_RET=1
			echo "WARNING: Minimum of 5 devices required for full coverage." >&2
		fi
	fi
	return $DEV_POOL_RET
}

if [ -z "$FSTESTS_SETUP_SYSTEM" ]; then
	FSTESTS_SETUP_SYSTEM="n"
fi

if [ -z "$FSTESTS_RUN_LARGE_DISK_TESTS" ]; then
	FSTESTS_RUN_LARGE_DISK_TESTS="n"
fi

if [[ "$LIMIT_TESTS" == "" ]]; then
	if [ "$FSTESTS_RUN_AUTO_GROUP_TESTS" = y ]; then
		_RUN_GROUPS="-g auto"
	elif [ -n "$FSTESTS_RUN_CUSTOM_GROUP_TESTS" ]; then
		_RUN_GROUPS="-g $FSTESTS_RUN_CUSTOM_GROUP_TESTS"
	fi
fi

# Where we stuff the arguments we will pass to ./check
declare -a CHECK_ARGS

if [ $(id -u) != "0" ]; then
	echo "Must run as root"
	exit 1
fi

parse_args $@

oscheck_lib_set_run_section $TEST_ARG_SECTION
oscheck_lib_get_host_options_vars

check_mount $TEST_DIR
if [ $? -eq 0 ]; then
	umount $TEST_DEV
fi

oscheck_lib_read_osfiles_verify_kernel

if [[ "$LIMIT_TESTS" == "" ]]; then
	oscheck_handle_skipping_group
fi

check_reqs
DEPS_RET=$?
if [ $DEPS_RET -ne 0 ]; then
	exit $DEPS_RET
fi

check_check
DEPS_RET=$?
if [ $DEPS_RET -ne 0 ]; then
	exit $DEPS_RET
fi

check_kernel_config
DEPS_RET=$?
if [ $DEPS_RET -ne 0 ]; then
	exit $DEPS_RET
fi

oscheck_lib_validate_section

echo "Testing section: $RUN_SECTION"

check_test_dev_setup
DEPS_RET=$?
if [ $DEPS_RET -ne 0 ]; then
	exit $DEPS_RET
fi

check_dev_pool
DEPS_RET=$?
if [ $DEPS_RET -ne 0 ]; then
	exit $DEPS_RET
fi

if [ "$ONLY_CHECK_DEPS" == "true" ]; then
	echo "Finished checking for dependencies"
fi

if [ $DEPS_RET -ne 0 ]; then
	exit $DEPS_RET
else
	if [ "$ONLY_CHECK_DEPS" == "true" ]; then
		exit 0
	fi
fi

oscheck_get_progs_version
oscheck_test_dev_setup

tmp=/tmp/$$
trap "_cleanup; exit \$status" 0 1 2 3 15

oscheck_lib_set_expunges
oscheck_run_section
