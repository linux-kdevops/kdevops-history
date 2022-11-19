#!/bin/bash
# SPDX-License-Identifier: copyleft-next-0.3.1

# Helper to get failures

OSCHECK_OSFILE_PREFIX=""
ONLY_TEST_GROUP=""
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

oscheck_fail_usage()
{
	echo "$0 - get failures"
	echo "--help          - Shows this menu"
	echo "--test-group <group> - Only run the tests for the specified group"
	echo ""
}

parse_args()
{
	while [[ ${#1} -gt 0 ]]; do
		key="$1"

		case $key in
		--test-group)
			ONLY_TEST_GROUP="$2"
			shift
			shift
			;;
		--help)
			oscheck_fail_usage
			exit
			;;
		*)
			oscheck_fail_usage
			exit
			;;
		esac
	done
}

parse_args $@

oscheck_lib_read_osfiles_verify_kernel
oscheck_lib_set_run_group $ONLY_TEST_GROUP
oscheck_lib_set_expunges

TMP=$(oscheck_lib_mktemp)
echo > $TMP

for i in $EXPUNGE_TESTS; do
	echo $i | awk '{print $1}' | sed -e '/^$/d' >> $TMP
done

cat $TMP | sort | uniq | sed -e '/^$/d'
rm -f $TMP
