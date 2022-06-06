#!/bin/bash
# Runs xfstests check.sh in a loop until a failure occurs, tells you
# how many runs are needed before a failure occurs.
#
# Example run in a loop until the first failure occurs:
#	./naggy-check.sh -s xfs -f generic/002
# Example run 100 times:
#	./naggy-check.sh -s xfs -c 100 generic/002

export HOST_OPTIONS=${HOST_OPTIONS:=local.config}
export FSTEST_DIR=${FSTEST_DIR:=/var/lib/xfstests}

trap "sig_exit" SIGINT SIGTERM

SECTION=""
NUM_TESTS="loop"
EXIT_ON_FAIL="false"
TESTS=""

# Modified to be run as part of root's .bashrc
known_hosts_local()
{
	[ "$HOST_CONFIG_DIR" ] || HOST_CONFIG_DIR=$FSTEST_DIR/configs

	[ -f /etc/xfsqa.config ]             && export HOST_OPTIONS=/etc/xfsqa.config
	[ -f $HOST_CONFIG_DIR/$HOST ]        && export HOST_OPTIONS=$HOST_CONFIG_DIR/$HOST
	[ -f $HOST_CONFIG_DIR/$HOST.config ] && export HOST_OPTIONS=$HOST_CONFIG_DIR/$HOST.config
}

get_config_sections() {
	sed -n -e "s/^\[\([[:alnum:]_-]*\)\]/\1/p" < $1
}

# Modified to be run as part of root's .bashrc
parse_config_section_local() {
	SECTION=$1
	if ! $OPTIONS_HAVE_SECTIONS; then
		return 0
	fi
	if [[ ! -f $HOST_OPTIONS ]]; then
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

sig_exit()
{
	echo "Caught signal, bailing..."
	exit 1
}

parse_args()
{
	while [[ $# -gt 0 ]]; do
	key="$1"

	case $key in
	    -s|--section)
	    SECTION="$2"
	    shift
	    shift
	    ;;
	    -c|--count)
	    NUM_TESTS="$2"
	    shift
	    shift
	    ;;
	    -f|--fail-triggers-exit)
	    EXIT_ON_FAIL="true"
	    shift
	    ;;
	    *)
	    TESTS="$TESTS $1"
	    shift
	    ;;
	esac
	done
}

HOST=`hostname -s`
if [ ! -f "$HOST_OPTIONS" ]; then
	known_hosts_local
fi

INFER_SECTION=$(echo $HOST | sed -e 's|-dev||')
INFER_SECTION=$(echo $INFER_SECTION | sed -e 's|-|_|g')
INFER_SECTION=$(echo $INFER_SECTION | awk -F"_" '{for (i=2; i <= NF; i++) { printf $i; if (i!=NF) printf "_"}; print NL}')

export OPTIONS_HAVE_SECTIONS=false
if [ -f "$HOST_OPTIONS" ]; then
	export HOST_OPTIONS_SECTIONS=`get_config_sections $HOST_OPTIONS`
	if [ -z "$HOST_OPTIONS_SECTIONS" ]; then
		. $HOST_OPTIONS
	else
		export OPTIONS_HAVE_SECTIONS=true
	fi
fi

parse_config_section_local default
parse_args $@
if [[ "$SECTION" == "" ]]; then
	SECTION=$INFER_SECTION
fi
parse_config_section_local $SECTION

if [ "$TESTS" = "" ]; then
	echo "Usage: $0 [ -s | --section <section> ] [ -c | --count <num-tests> ] [ -f | --fail-triggers-exit ] <tests>"
	exit 1
fi

i=0

while true; do
	FAIL="false"
	./check -s $SECTION $TESTS
	RET=$?
	# Fortunately check will return 1 if any test fails
	if [ $RET -ne 0 ]; then
		FAIL="true"
	fi

	if [ "$FAIL" = "false" ]; then
		echo "PASS $i ... $TESTS"
	else
		# Only if there was a failure itemize which tests passed, and which ones failed,
		# otherwise as reflected above we print that all tests passed.
		for TEST in $TESTS; do
			if [ ! -f xfstests-dev/results/$(hostname)/$(uname -r)/${SECTION}/${TEST}.out.bad -a \
			     ! -f xfstests-dev/results/$(hostname)/$(uname -r)/${SECTION}/${TEST}.dmesg ]; then
				echo "PASS $i ... $TEST"
			else
				echo "FAIL $i ... $TEST"
			fi
		done
		if [ "$EXIT_ON_FAIL" = "true" ]; then
			exit $RET
		fi
	fi
	let i=$i+1
done

exit 0
