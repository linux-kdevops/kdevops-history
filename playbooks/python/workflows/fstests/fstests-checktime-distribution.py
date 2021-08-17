#!/usr/bin/python3
# SPDX-License-Identifier: copyleft-next-0.3.1

# Create fstests check.time.distribution file, this file groups together
# all tests which run the same amount of time, and gives you an idea of how
# many tests that consists of. A CSV file is created with the columns
# representing:
#
# time-segment number-of-tests-which-take-this-amount-of-time percentage

import argparse
import os
import sys
import re
import subprocess
import collections

oscheck_ansible_python_dir = os.path.dirname(os.path.abspath(__file__))
oscheck_sort_expunge = oscheck_ansible_python_dir + "/../../../scripts/workflows/fstests/sort-expunges.sh"

def main():
    parser = argparse.ArgumentParser(description='Creates check.time.distribution files for all found check.time files')
    parser.add_argument('results', metavar='<directory with check.time files>', type=str,
                        help='directory with check.time files')
    args = parser.parse_args()

    expunge_kernel_dir = ""

    all_files = os.listdir(args.results)

    for root, dirs, all_files in os.walk(args.results):
        for fname in all_files:
            f = os.path.join(root, fname)
            #sys.stdout.write("%s\n" % f)
            if os.path.isdir(f):
                continue
            if not os.path.isfile(f):
                continue
            if not f.endswith('check.time'):
                continue

            # f may be results/oscheck-xfs/4.19.0-4-amd64/check.time
            time_distribution = f + '.distribution'

            if os.path.isfile(time_distribution):
                os.unlink(time_distribution)

            checktime = open(f, 'r')
            distribution = open(time_distribution, 'w')

            sys.stdout.write("checktime: %s\n" % f)

            all_lines = checktime.readlines()
            checktime.close()

            results = {}
            num_tests = 0
            for line in all_lines:
                line = line.strip()
                m = re.match(r"^(?P<GROUP>\w+)/"
                              "(?P<NUMBER>\d+)\s+"
                              "(?P<TIME>\d+)$", line)
                if not m:
                    continue
                testline = m.groupdict()
                num_tests += 1
                if int(testline['TIME']) in results:
                    results[int(testline['TIME'])] += 1
                else:
                    results[int(testline['TIME'])] = 1
            od = collections.OrderedDict(sorted(results.items()))

            v_total = 0
            for k, v in od.items():
                distribution.write("%d,%d,%f\n" % (k, v, 100 * v / num_tests))
                v_total += v

            if num_tests != v_total:
                sys.stdout.write("Unexpected error, total tests: %d but computed sum test: %d\n" % (num_tests, v_total))


if __name__ == '__main__':
    main()
