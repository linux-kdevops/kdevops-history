# Generic oscheck library

oscheck_lib_init_vars()
{
	if [ -z "$FSTYP" ]; then
		echo "FSTYP needs to be set"
		exit 1
	fi

	export OS_FILE="/etc/os-release"
	export RUN_SECTION=""

	if [ -z "$OSCHECK_INCLUDE_PATH" ]; then
		export OSCHECK_INCLUDE_PATH="${OSCHECK_DIR}/../osfiles"
	fi

	if [ ! -z "$OSCHECK_OS_FILE" ]; then
		OS_FILE="$OSCHECK_OS_FILE"
	fi

	export OS_SECTION_PREFIX=""

	if [ -z "$OSCHECK_EXCLUDE_PREFIX" ]; then
		export OSCHECK_EXCLUDE_PREFIX="$(dirname $(readlink -f $0))/../expunges/"
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

	# fstests check.sh uses $ID for the test number, so we need to use something
	# more unique. For example, on Debian this is "debian" for opensuse factory
	# this is "opensuse" and for OpenSUSE Leap this is "opensuse-leap".
	export OSCHECK_ID=""
	# VERSION_ID is 15.0 for OpenSUSE Leap 15.0, but Debian testing lacks VERSION_ID.
	export VERSION_ID=""

	# Used to do a sanity check that the section we are running a test
	# for has all intended files part of its expunge list. Updated per
	# section run.
	export OSCHECK_EXCLUDE_DIR=""
	export EXPUNGE_FILES=""

	if [ -z "$OSCHECK_ONLY_RUN_DISTRO_KERNEL" ]; then
		export OSCHECK_ONLY_RUN_DISTRO_KERNEL="false"
	fi

	if [ -z "$OSCHECK_CUSTOM_KERNEL" ]; then
		export OSCHECK_CUSTOM_KERNEL="false"
	fi

	export KERNEL_VERSION=$(uname -r)
	if [ ! -z "$FSTESTS_LINUX_LOCALVERSION" ]; then
		# Strip localversion to use the expunge lists of baseline version
		export KERNEL_VERSION=${KERNEL_VERSION%$FSTESTS_LINUX_LOCALVERSION}
	fi

	# Set this to true to only output if we're on a custom kernel or not.
	# This is useful for enterprise distributions which want to take
	# care to only run tests on their distro kernels. So an "os" check
	# exists for them to query this. This is distro specific.
	#
	# Setting this to true will *only* do that check and bail out.
	# Once oscheck_distro_kernel_check is run.
	export ONLY_QUESTION_DISTRO_KERNEL="false"

	oscheck_set_host_config_vars
}

known_hosts()
{
	[ "$HOST_CONFIG_DIR" ] || HOST_CONFIG_DIR=`pwd`/configs

	[ -f /etc/xfsqa.config ]             && export HOST_OPTIONS=/etc/xfsqa.config
	[ -f $HOST_CONFIG_DIR/$HOST ]        && export HOST_OPTIONS=$HOST_CONFIG_DIR/$HOST
	[ -f $HOST_CONFIG_DIR/$HOST.config ] && export HOST_OPTIONS=$HOST_CONFIG_DIR/$HOST.config
}

oscheck_lib_set_run_section()
{
	LOCAL_TEST_ARG_SECTION="$1"

	INFER_SECTION=$(echo $HOST | sed -e 's|-dev||')
	INFER_SECTION=$(echo $INFER_SECTION | sed -e 's|-|_|g')
	INFER_SECTION=$(echo $INFER_SECTION | awk -F"_" '{for (i=2; i <= NF; i++) { printf $i; if (i!=NF) printf "_"}; print NL}')

	if [[ "$LOCAL_TEST_ARG_SECTION" != "" ]]; then
		RUN_SECTION=$LOCAL_TEST_ARG_SECTION
	else
		RUN_SECTION=$INFER_SECTION
	fi

	if [ "${RUN_SECTION}" != "${FSTYP}" ] && [ "${RUN_SECTION}" != "all" ]; then
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
}

# Set's the HOST and HOST_OPTIONS variables
oscheck_set_host_config_vars()
{
	export HOST_OPTIONS=${HOST_OPTIONS:=local.config}
	export HOST=`hostname -s`
	if [ ! -f "$HOST_OPTIONS" ]; then
		known_hosts
	fi
}

parse_config_section() {
	LOCAL_SECTION=$1
	if ! $OPTIONS_HAVE_SECTIONS; then
		return 0
	fi

	if [ "${LOCAL_SECTION}" == "all" ]; then
		return 0
	fi

	eval `sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' \
		-e 's/#.*$//' \
		-e 's/[[:space:]]*$//' \
		-e 's/^[[:space:]]*//' \
		-e "s/^\([^=]*\)=\"\?'\?\([^\"']*\)\"\?'\?$/export \1=\"\2\"/" \
		< $HOST_OPTIONS \
		| sed -n -e "/^\[$LOCAL_SECTION\]/,/^\s*\[/{/^[^#].*\=.*/p;}"`
}

oscheck_lib_get_host_options_vars()
{
	parse_config_section default
	parse_config_section $RUN_SECTION
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

	if [ "$TARGET_SECTION" == "all" ]; then
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

oscheck_prefix_section()
{
	ADD_SECTION="$1"
	if [ "$ADD_SECTION" == "all" ]; then
		return 0;
	fi
	if [ "$OS_SECTION_PREFIX" != "" ]; then
		if [ "${ADD_SECTION}" != "${FSTYP}" ]; then
			SECTION="${OS_SECTION_PREFIX}_${ADD_SECTION}"
		else
			SECTION="${OS_SECTION_PREFIX}_${FSTYP}"
		fi
	fi
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

oscheck_lib_read_osfiles_verify_kernel()
{
	oscheck_read_osfile_and_includes
	oscheck_distro_kernel_check
}

check_section()
{
	if [ ! -e $HOST_OPTIONS ]; then
		return 0;
	fi
	if [ "${RUN_SECTION}" == "all" ]; then
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
