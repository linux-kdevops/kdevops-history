#!/bin/bash
# Runs xfstests check.sh in a loop until a failure occurs, tells you
# how many runs are needed before a failure occurs.
#
# Example run in a loop until the first failure occurs:
#	./naggy-check.sh -s xfs -f generic/002
# Example run 100 times:
#	./naggy-check.sh -s xfs -c 100 generic/002

trap "sig_exit" SIGINT SIGTERM

SECTION="xfs"
NUM_TESTS="loop"
EXIT_ON_FAIL="false"
TESTS=""

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

parse_args $@

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
