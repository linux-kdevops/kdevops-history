#!/bin/bash
# Gets the the list of known failed tests.

TEST_ARG_SECTION=""
OSCHECK_LIB_SKIP_NON_FAILURE_EXPUNGES="y"
OSCHECK_LIB_CHATTY_DISTRO_CHECK="n"

OSCHECK_DIR="$(dirname $(readlink -f $0))"
OSCHECK_LIB="$OSCHECK_DIR/oscheck-lib.sh"
if [ ! -f $OSCHECK_LIB ]; then
	echo "Missing oscheck library: $OSCHECK_LIB"
	exit 1
fi
source $OSCHECK_LIB
oscheck_lib_init_vars

oscheck_get_failures_usage()
{
	echo "$0 - gets the list of known failed tests"
	echo "--help          - Shows this menu"
	echo "--test-section <section> - Get the failures for this section"
	echo "--verbose       - Be verbose when debugging"
	echo ""
}

parse_args()
{
	while [[ ${#1} -gt 0 ]]; do
		key="$1"

		case $key in
		--test-section)
			TEST_ARG_SECTION="$2"
			shift
			shift
			;;
		--help)
			oscheck_get_failures_usage
			exit
			;;
		*)
			oscheck_get_failures_usage
			exit 1
			;;
		esac
	done
}

parse_args $@

oscheck_lib_set_run_section $TEST_ARG_SECTION
oscheck_lib_get_host_options_vars
oscheck_lib_read_osfiles_verify_kernel
oscheck_lib_validate_section
oscheck_lib_set_expunges

TMP=$(oscheck_lib_mktemp)
echo > $TMP

for i in $EXPUNGE_FILES; do
	cat $i | awk '{print $1}' | sed -e '/^$/d' >> $TMP
done

cat $TMP | sort | uniq | sed -e '/^$/d'
rm -f $TMP
