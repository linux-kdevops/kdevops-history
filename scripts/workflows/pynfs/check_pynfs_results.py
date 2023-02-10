#!/usr/bin/python3

#
# Usage: check_pynfs_results.py <baseline> <new>
#
# Compare a set of new json results from pynfs to an existing baseline set.
# Return 0 if there are no new failures in the result set vs. base. Otherwise
# print the new failures and exit with a status of 1.
#

import json
import sys
import pprint

def main():
    base = json.load(open(sys.argv[1]))
    result = json.load(open(sys.argv[2]))

    failures = {}

    for case in result['testcase']:
        if 'failure' in case:
            failures[case['code']] = case

    for case in base['testcase']:
        if 'failure' in case:
            if case['code'] in failures:
                del failures[case['code']]

    if len(failures) != 0:
        pprint.pprint(failures)
        sys.exit(1)
    else:
        sys.exit(0)

if __name__ == "__main__":
    main()

