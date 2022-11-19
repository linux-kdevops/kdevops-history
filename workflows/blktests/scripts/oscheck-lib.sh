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
			echo "Only testing group: $LOCAL_TEST_GROUP"
		else
			RUN_GROUP="$INFER_GROUP"
			echo "Only testing inferred group: $RUN_GROUP"
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
			${OSCHECK_ID}_read_osfile > /dev/null
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

oscheck_lib_read_osfiles_verify_kernel()
{
	oscheck_read_osfile_and_includes
	oscheck_distro_kernel_check
}
