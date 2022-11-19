# Generic oscheck library

oscheck_lib_init_vars()
{
	export OS_FILE="/etc/os-release"

	if [ -z "$OSCHECK_INCLUDE_PATH" ]; then
		export OSCHECK_DIR="$(dirname $(readlink -f $0))"
		export OSCHECK_INCLUDE_PATH="${OSCHECK_DIR}/../osfiles"
	fi

	if [ ! -z "$OSCHECK_OS_FILE" ]; then
		export OS_FILE="$OSCHECK_OS_FILE"
	fi

	if [ -z "$OSCHECK_EXCLUDE_PREFIX" ]; then
		export OSCHECK_EXCLUDE_PREFIX="$(dirname $(readlink -f $0))/../results/"
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

	# blktests check uses $ID for the test number, so we need to use something
	# more unique. For example, on Debian this is "debian" for opensuse factory
	# this is "opensuse" and for OpenSUSE Leap this is "opensuse-leap".
	export OSCHECK_ID=""
	# VERSION_ID is 15.0 for OpenSUSE Leap 15.0, but Debian testing lacks VERSION_ID.
	export VERSION_ID=""

	# Used to do a sanity check that the section we are running a test
	# for has all intended files part of its expunge list. Updated per
	# section run.
	export OSCHECK_EXCLUDE_DIR=""

	export EXPUNGE_TESTS=""
	export EXPUNGE_TESTS_COUNT=0

	export RUN_GROUP=""

	export VALID_GROUPS="block"
	VALID_GROUPS="$VALID_GROUPS loop"
	VALID_GROUPS="$VALID_GROUPS meta"
	VALID_GROUPS="$VALID_GROUPS nbd"
	VALID_GROUPS="$VALID_GROUPS nvme"
	VALID_GROUPS="$VALID_GROUPS nvmeof-mp"
	VALID_GROUPS="$VALID_GROUPS scsi"
	VALID_GROUPS="$VALID_GROUPS srp"
	VALID_GROUPS="$VALID_GROUPS zbd"

	if [ -z "$OSCHECK_LIB_CHATTY_DISTRO_CHECK" ]; then
		export OSCHECK_LIB_CHATTY_DISTRO_CHECK="y"
	fi

	# Set this to true to only output if we're on a custom kernel or not.
	# This is useful for enterprise distributions which want to take
	# care to only run tests on their distro kernels. So an "os" check
	# exists for them to query this. This is distro specific.
	#
	# Setting this to true will *only* do that check and bail out.
	# Once oscheck_distro_kernel_check is run.
	export ONLY_QUESTION_DISTRO_KERNEL="false"

	export OSCHECK_OSFILE_PREFIX=""
	export OSCHECK_SUBSYSTEM="blktests"

	if [ ! -z "$OSCHECK_SUBSYSTEM" ]; then
		OSCHECK_OSFILE_PREFIX="_blktests"
	fi

	if [ -z "$OSCHECK_ONLY_RUN_DISTRO_KERNEL" ]; then
		OSCHECK_ONLY_RUN_DISTRO_KERNEL="false"
	fi

	if [ -z "$OSCHECK_CUSTOM_KERNEL" ]; then
		OSCHECK_CUSTOM_KERNEL="false"
	fi
	export EXPUNGE_FLAGS=""
}

validate_run_group()
{
	VALID_GROUP="false"
	for i in $VALID_GROUPS; do
		if [[ "$RUN_GROUP" == "$i" ]]; then
			VALID_GROUP="true"
		fi
	done
	if [[ "$VALID_GROUP" != "true" ]]; then
		echo "Invalid group: $RUN_GROUP"
		echo "Allowed groups: $VALID_GROUPS"
		exit 1
	fi
}

oscheck_lib_set_run_group()
{
	LOCAL_TEST_GROUP=$1

	INFER_GROUP=$(echo $HOST | sed -e 's|-dev||')
	INFER_GROUP=$(echo $INFER_GROUP | sed -e 's|-|_|g')
	INFER_GROUP=$(echo $INFER_GROUP | awk -F"_" '{for (i=2; i <= NF; i++) { printf $i; if (i!=NF) printf "_"}; print NL}')

	if [[ "$LIMIT_TESTS" == "" ]]; then
		if [ "$LOCAL_TEST_GROUP" != "" ]; then
			RUN_GROUP="$LOCAL_TEST_GROUP"
			if [[ "$OSCHECK_LIB_CHATTY_DISTRO_CHECK" == "y" ]]; then
				echo "Only testing group: $LOCAL_TEST_GROUP"
			fi
		else
			RUN_GROUP="$INFER_GROUP"
			if [[ "$OSCHECK_LIB_CHATTY_DISTRO_CHECK" == "y" ]]; then
				echo "Only testing inferred group: $RUN_GROUP"
			fi
		fi
		validate_run_group
	fi
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
		if [[ "$OSCHECK_LIB_CHATTY_DISTRO_CHECK" == "n" ]]; then
			${OSCHECK_ID}_read_osfile > /dev/null
		else
			${OSCHECK_ID}_read_osfile
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
			if [[ "$OSCHECK_LIB_CHATTY_DISTRO_CHECK" == "y" ]]; then
				echo "Running custom kernel: $(uname -a)"
			fi
		else
			if [ "$ONLY_QUESTION_DISTRO_KERNEL" = "true" ]; then
				if [[ "$OSCHECK_LIB_CHATTY_DISTRO_CHECK" == "y" ]]; then
					echo "Running distro kernel"
					uname -a
				fi
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
	BAD_FILES=""
	if [[ -d $BLOCK_EXCLUDE_DIR ]]; then
		BAD_FILES=$(find $BLOCK_EXCLUDE_DIR -type f \( -iname \*.bad -o -iname \*.dmesg \) | sed -e 's|'$BLOCK_EXCLUDE_DIR'||')
	fi
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
	if [ -e $OS_FILE ]; then
		OSCHECK_EXPUNGE_FILE="$(dirname $(readlink -f $0))/../expunges/${OSCHECK_ID}/${VERSION_ID}/failures.txt"
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
	fi
}

oscheck_count_check()
{
	if [[ "$EXPUNGE_TESTS_COUNT" -eq 0 ]]; then
		if [[ "$RUN_GROUP" != "" ]]; then
			if [[ "$OSCHECK_LIB_CHATTY_DISTRO_CHECK" == "y" ]]; then
				echo "No expunges for blktests on test group $GROUP -- a perfect kernel!"
			fi
		else
			if [[ "$OSCHECK_LIB_CHATTY_DISTRO_CHECK" == "y" ]]; then
				echo "No expunges for blktests -- a perfect kernel!"
			fi
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

oscheck_lib_set_expunges()
{
	if [[ "$LIMIT_TESTS" == "" ]]; then
		oscheck_handle_group_expunges
		oscheck_count_check
	fi
}
