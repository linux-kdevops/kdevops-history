#!/usr/bin/python3
# SPDX-License-Identifier: copyleft-next-0.3.1

# Generate expunge arguments for a blktest group type given a results
# directory
#
# Given a directory path it finds all test failures and augments your
# existing expunge list you can use with oscheck. If a failure was
# present it will not be added again. If you had no expunge files,
# they will be created for you.

import argparse
import os
import sys
import subprocess

def main():
    parser = argparse.ArgumentParser(description='Generates expunge arguments to run blktests check based on results directory')
    parser.add_argument('--test-group', metavar='<group>', type=str,
                        help='group of tests to focus on otherwise all groups are considered')
    parser.add_argument('results', metavar='<directory with blktests results>', type=str,
                        help='directory with blktests results')
    parser.add_argument('--gen-exclude-args', const=True, default=False, action="store_const",
                        help='Generate exclude arguments so to be passed to blktests check')
    parser.add_argument('--verbose', const=True, default=False, action="store_const",
                        help='Print more verbose information')
    args = parser.parse_args()

    bad_files = []
    for root, dirs, all_files in os.walk(args.results):
        for fname in all_files:
            f = os.path.join(root, fname)
            if os.path.isdir(f):
                continue
            if not os.path.isfile(f):
                continue
            if f.endswith('.bad') or f.endswith('.dmesg'):
                bad_files.append(f)
                continue
    exclude_args = ""
    for f in bad_files:
        if args.verbose:
            sys.stdout.write("Processing bad/dmesg file: %s\n" % f)

        # f may be something like:
        # ../workflows/blktests/results/nvme2n1/block/011.out.bad
        # ../workflows/blktests/results/nodev/meta/009.dmesg
        bad_file_list = f.split(args.results)
        if not bad_file_list or len(bad_file_list) < 2:
            continue
        bad_file = bad_file_list[1]
        if len(bad_file.split("/")) != 4:
            continue
        ignore, block_device, group, test_failure = bad_file.split("/")
        if len(test_failure.split(".")) < 2:
            continue
        fail = test_failure.split(".")[0]
        if args.test_group and args.test_group != group:
            continue
        if args.gen_exclude_args:
            exclude_args += (" -x %s/%s" % (group, fail))
        else:
            sys.stdout.write("%s/%s\n" % (group, fail))

    if args.gen_exclude_args:
        sys.stdout.write("%s\n" % (exclude_args))

if __name__ == '__main__':
    main()
