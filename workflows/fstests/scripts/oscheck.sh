#!/bin/bash
# OS wrapper for check.sh

OS_FILE="/etc/os-release"
DRY_RUN="false"
EXPUNGE_FLAGS=""
ONLY_SHOW_CMD="false"
VERBOSE="false"
TEST_ARG_SECTION=""
ONLY_CHECK_DEPS="false"
ONLY_QUESTION_DISTRO_KERNEL="false"
PRINT_START="false"
PRINT_DONE="false"
RUN_SECTION=""

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

# fstests check.sh uses $ID for the test number, so we need to use something
# more unique. For example, on Debian this is "debian" for opensuse factory
# this is "opensuse" and for OpenSUSE Leap this is "opensuse-leap".
OSCHECK_ID=""
# VERSION_ID is 15.0 for OpenSUSE Leap 15.0, but Debian testing lacks VERSION_ID.
VERSION_ID=""


# Used to do a sanity check that the section we are running a test
# for has all intended files part of its expunge list. Updated per
# section run.
OSCHECK_EXCLUDE_DIR=""
EXPUNGE_FILES=""

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

known_hosts()
{
	[ "$HOST_CONFIG_DIR" ] || HOST_CONFIG_DIR=`pwd`/configs

	[ -f /etc/xfsqa.config ]             && export HOST_OPTIONS=/etc/xfsqa.config
	[ -f $HOST_CONFIG_DIR/$HOST ]        && export HOST_OPTIONS=$HOST_CONFIG_DIR/$HOST
	[ -f $HOST_CONFIG_DIR/$HOST.config ] && export HOST_OPTIONS=$HOST_CONFIG_DIR/$HOST.config
}

parse_config_section() {
	SECTION=$1
	if ! $OPTIONS_HAVE_SECTIONS; then
		return 0
	fi
	eval `sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' \
		-e 's/#.*$//' \
		-e 's/[[:space:]]*$//' \
		-e 's/^[[:space:]]*//' \
		-e "s/^\([^=]*\)=\"\?'\?\([^\"']*\)\"\?'\?$/export \1=\"\2\"/" \
		< $HOST_OPTIONS \
		| sed -n -e "/^\[$SECTION\]/,/^\s*\[/{/^[^#].*\=.*/p;}"`
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

oscheck_add_expunge_if_exists()
{
	if [ "$EXPUNGE_LIST" = "true" ]; then
		echo "$1"
	fi
	if [ -e $1 ]; then
		EXPUNGE_FLAGS="$EXPUNGE_FLAGS -E ${1}"
	fi
}

os_has_special_expunges()
{
	if [ ! -e $OS_FILE ]; then
		return 1
	fi
	declare -f ${OSCHECK_ID}_special_expunges > /dev/null;
	return $?
}

oscheck_handle_special_expunges()
{
	os_has_special_expunges $OSCHECK_ID
	if [ $? -eq 0 ] ; then
		${OSCHECK_ID}_special_expunges
	fi
}

oscheck_get_section_files()
{
	for CATEGORY in $CATEGORIES; do
		PROCESS_DIRS="$ALWAYS_USE $SECTION"
		for TRY_SECTION in $PROCESS_DIRS; do
			TRY_PATH="$FS_EXCLUDE_DIR/$CATEGORY/$TRY_SECTION"
			TRY_PATH_FILE="${TRY_PATH}.txt"
			oscheck_add_expunge_if_exists $TRY_PATH_FILE
			for P in $PRIORITIES; do
				P_TEST_FILE="$FS_EXCLUDE_DIR/${CATEGORY}/${P}/${TRY_SECTION}.txt"
				oscheck_add_expunge_if_exists $P_TEST_FILE
			done
		done
	done
}

oscheck_update_expunge_files()
{
	EXPUNGE_FILES=""
	for y in $EXPUNGE_FLAGS; do
		case $y in
		-E)
			shift
			;;
		*)
			if [ -e $y ]; then
				EXPUNGE_FILES="$EXPUNGE_FILES $y"
			fi
			;;
		esac
	done
}

oscheck_get_expunge_count()
{
	COUNT=0

	for z in $EXPUNGE_FILES; do
		let COUNT=$COUNT+1
	done

	echo $COUNT
}

oscheck_count_check()
{
	EXPUNGE_COUNT="$(oscheck_get_expunge_count)"
	if [[ "$EXPUNGE_COUNT" -eq 0 ]]; then
		echo "No expunges for filesystem $FSTYP on section $SECTION -- a perfect kernel!"
	fi
}

oscheck_expunge_file_queued()
{
	INODE_ITER="$(ls -i $1 | awk '{print $1}')"

	for x in $EXPUNGE_FILES; do
		INODE_FILE="$(ls -i $x | awk '{print $1}')"
		if [ "$INODE_FILE" == "$INODE_ITER" ]; then
			return 1
		fi
	done

	return 0
}

oscheck_verify_intented_expunges()
{
	TARGET_SECTION="$1"
	MISSING_EXPUNGE="false"

	if [ ! -d "$OSCHECK_EXCLUDE_DIR" ]; then
		return 0
	fi

	INTENDED_SECTION_EXPUNGES="$(find $OSCHECK_EXCLUDE_DIR -type f)"
	for i in $INTENDED_SECTION_EXPUNGES; do
		# Is this a section specific file? If so then only test
		# for it if we are running against that target section.
		FILE_SECTION="$(basename $i | sed -e 's|.txt||')"
		echo $FILE_SECTION | grep -q $FSTYP
		if [ $? -eq 0 ]; then
			if [ "$FILE_SECTION" !=  "$TARGET_SECTION" ]; then
				continue
			fi
		fi
		oscheck_expunge_file_queued $i
		if [ $? -ne 1 ]; then
			echo "Expunge file $i never queued up, verify name, or report this as a bug"
			echo "To debug use:"
			echo "$0 -n --expunge-list"
			echo "And also:"
			echo "$0 -n -show-cmd"
			MISSING_EXPUNGE="true"
		fi
	done

	if [ "$MISSING_EXPUNGE" == "true" ]; then
		echo "Missing expunge files on queue list... verify your expunge files."
		exit 1
	fi
}

oscheck_handle_section_expunges()
{
	CATEGORIES="diff unassigned assigned"
	# We optionally allow to triage the failures
	PRIORITIES="P0 P1 P2 P3 P4 P5"
	# These are files which always should be used for all sections
	# We allow future expansion on this to enable grouping failures
	# into groups.
	# 'progs' is a group for failures in userspace tools (e.g. xfsprogs)
	# those should also be split by specific tools and versions
	ALWAYS_USE="all progs"

	EXPUNGE_FLAGS=""

	if [ "$EXPUNGE_LIST" = "true" ]; then
		echo "List of possible expunge files for section $SECTION :"
	fi

	if [ ! -z "$FAST_TEST" ]; then
		oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/over-10s.txt"
		oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/$FSTYP/over-10s.txt"
	fi

	if [ "$FSTESTS_RUN_LARGE_DISK_TESTS" != "y" ]; then
		oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/large-disk.txt"
		oscheck_add_expunge_if_exists "${OSCHECK_EXCLUDE_PREFIX}/any/$FSTYP/large-disk.txt"
	fi

	oscheck_handle_special_expunges

	if [ -e $OS_FILE ]; then
		FS_EXCLUDE_DIR="${OSCHECK_EXCLUDE_PREFIX}/${OSCHECK_ID}/${VERSION_ID}/${FSTYP}/"
		OSCHECK_EXCLUDE_DIR="$FS_EXCLUDE_DIR"
		if [ "$OSCHECK_CUSTOM_KERNEL" == "true" ]; then
			if [ "$OSCHECK_ONLY_RUN_DISTRO_KERNEL" != "true" ]; then
				# XXX: make this userspace progs specific as well?
				FS_EXCLUDE_DIR="${OSCHECK_EXCLUDE_PREFIX}/${KERNEL_VERSION}/${FSTYP}/"
				OSCHECK_EXCLUDE_DIR="$FS_EXCLUDE_DIR"
			fi
		fi
		oscheck_get_section_files
	fi

	# One more check for distro agnostic expunges. Right now this is just an
	# informal group listing. Only files named after a section would be treated
	# as generic expunges for the filesystem, but as of right now we have none.
	FS_EXCLUDE_DIR="${OSCHECK_EXCLUDE_PREFIX}/any/${FSTYP}/"
	# Don't update OSCHECK_EXCLUDE_DIR as these are extra files only.
	oscheck_get_section_files
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

oscheck_prefix_section()
{
	ADD_SECTION="$1"
	if [ "$OS_SECTION_PREFIX" != "" ]; then
		if [ "${ADD_SECTION}" != "${FSTYP}" ]; then
			SECTION="${OS_SECTION_PREFIX}_${ADD_SECTION}"
		else
			SECTION="${OS_SECTION_PREFIX}_${FSTYP}"
		fi
	fi
}

oscheck_run_cmd()
{
	if [ "$ONLY_SHOW_CMD" = "false" ]; then
		LC_ALL=C bash --posix $OSCHECK_CMD
	else
		echo "LC_ALL=C bash --posix $OSCHECK_CMD"
	fi
}

oscheck_run_section()
{
	if [[ "$PRINT_START" == "true" ]]; then
		NOW=$(date --rfc-3339='seconds' | awk -F"+" '{print $1}')
		echo "run fstests fstestsstart/000 at $NOW" > /dev/kmsg
	fi
	SECTION=$RUN_SECTION
	oscheck_prefix_section $SECTION
	oscheck_handle_section_expunges

	oscheck_update_expunge_files
	oscheck_count_check
	oscheck_verify_intented_expunges $SECTION

	OSCHECK_CMD="./check -s ${SECTION} -R xunit $_SKIP_GROUPS $EXPUNGE_FLAGS $CHECK_ARGS"
	oscheck_run_cmd
	if [[ "$PRINT_DONE" == "true" ]]; then
		NOW=$(date --rfc-3339='seconds' | awk -F"+" '{print $1}')
		echo "run fstests fstestsdone/000 at $NOW" > /dev/kmsg
	fi
}

oscheck_test_dev_setup()
{
	if [ "$DRY_RUN" = "true" ]; then
		return
	fi

	blkid -t TYPE=$FSTYP $TEST_DEV /dev/null
	if [[ $? -ne 0 ]]; then
		echo "FSTYP: $FSTYP Section: $INFER_SECTION with TEST_DEV: $TEST_DEV and MKFS_OPTIONS: $MKFS_OPTIONS TEST_DIR: $TEST_DIR"
		CMD="mkfs.$FSTYP $MKFS_OPTIONS $TEST_DEV"
		echo "$CMD"
		$CMD
	fi

	if [[ ! -d  $TEST_DIR ]]; then
		mkdir -p $TEST_DIR
	fi
	check_mount $TEST_DIR
	if [ $? -ne 0 ]; then
		mount $TEST_DEV $TEST_DIR
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
			KERNEL_VERSION=$(uname -r)
			if [ ! -z "$CONFIG_BOOTLINUX_TREE_LOCALVERSION" ]; then
				# Strip localversion to use the expunge lists of baseline version
				KERNEL_VERSION=${KERNEL_VERSION%$CONFIG_BOOTLINUX_TREE_LOCALVERSION}
			fi
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

	if [[ ! -e $TEST_DEV ]]; then
		echo "$TEST_DEV is not present"
		DEV_SETUP_RET=1
	fi
	return $DEV_SETUP_RET
}

check_dev_pool()
{
	DEV_POOL_RET=0
	if [ -e $HOST_OPTIONS ]; then
		NDEVS=$(echo $SCRATCH_DEV_POOL|wc -w)
		if [ "$NDEVS" -lt 5 ]; then
			DEV_POOL_RET=1
			echo "WARNING: Minimum of 5 devices required for full coverage." >&2
		fi
	fi
	return $DEV_POOL_RET
}

check_section()
{
	if [ ! -e $HOST_OPTIONS ]; then
		return 0;
	fi
	ALL_FS_SECTIONS=$(grep "^\[" $HOST_OPTIONS | grep -v "^\[default\]" | sed -e 's|\[||' | sed -e 's|\]||')
	SECTION=$RUN_SECTION
	RUN_SECTION_FOUND=0
	for valid_section in $ALL_FS_SECTIONS; do
		if [[ "$SECTION" == "$valid_section" ]]; then
			RUN_SECTION_FOUND=1
		fi
	done
	if [ $RUN_SECTION_FOUND -ne 1 ]; then
		echo "Invalid section: $SECTION"
		echo "This section name is not present on the file $HOST_OPTIONS"
		echo "Valid sections: $ALL_FS_SECTIONS"
		return 1
	fi
	return 0
}

if [ -z "$FSTESTS_SETUP_SYSTEM" ]; then
	FSTESTS_SETUP_SYSTEM="n"
fi

if [ -z "$OSCHECK_ONLY_RUN_DISTRO_KERNEL" ]; then
	OSCHECK_ONLY_RUN_DISTRO_KERNEL="false"
fi

if [ -z "$OSCHECK_CUSTOM_KERNEL" ]; then
	OSCHECK_CUSTOM_KERNEL="false"
fi

if [ -z "$FSTESTS_RUN_LARGE_DISK_TESTS" ]; then
	FSTESTS_RUN_LARGE_DISK_TESTS="n"
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


parse_args $@

HOST=`hostname -s`
if [ ! -f "$HOST_OPTIONS" ]; then
	known_hosts
fi

INFER_SECTION=$(echo $HOST | sed -e 's|-dev||')
INFER_SECTION=$(echo $INFER_SECTION | sed -e 's|-|_|g')
INFER_SECTION=$(echo $INFER_SECTION | awk -F"_" '{for (i=2; i <= NF; i++) { printf $i; if (i!=NF) printf "_"}; print NL}')

if [[ "$TEST_ARG_SECTION" != "" ]]; then
	RUN_SECTION=$TEST_ARG_SECTION
else
	RUN_SECTION=$INFER_SECTION
fi

if [ "${RUN_SECTION}" != "${FSTYP}" ]; then
	# If you specified a section but it does not have the filesystem
	# prefix, we add it for you. Likewise, this means that if you
	# used oscheck.sh --test-section, we will allow you to specify
	# either the full section name, ie, xfs_reflink, or just the
	# short name, ie, reflink and we'll add the xfs prefix for you.
	echo $RUN_SECTION | grep -q ^${FSTYP}
	if [ $? -ne 0 ]; then
		RUN_SECTION="${FSTYP}_${s}"
	fi
fi

parse_config_section default
parse_config_section $RUN_SECTION
check_mount $TEST_DIR
if [ $? -eq 0 ]; then
	umount $TEST_DEV
fi

if [ ! -z "$OSCHECK_OS_FILE" ]; then
	OS_FILE="$OSCHECK_OS_FILE"
fi

OS_SECTION_PREFIX=""

if [ -z "$OSCHECK_EXCLUDE_PREFIX" ]; then
	OSCHECK_EXCLUDE_PREFIX="$(dirname $(readlink -f $0))/../expunges/"
fi

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


oscheck_read_osfile_and_includes
oscheck_distro_kernel_check

if [ -z "$FSTYP" ]; then
	echo "FSTYP needs to be set"
	exit
fi

oscheck_handle_skipping_group

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

check_section
DEPS_RET=$?
if [ $DEPS_RET -ne 0 ]; then
	exit $DEPS_RET
fi

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

oscheck_run_section
