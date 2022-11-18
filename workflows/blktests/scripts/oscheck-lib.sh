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
}
