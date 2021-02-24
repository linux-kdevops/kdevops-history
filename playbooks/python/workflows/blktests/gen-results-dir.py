#!/usr/bin/python3
# SPDX-License-Identifier: GPL-2.0

# Trim results only keeping *.bad *.dmesg and respective files and move these
# to their respective kernel directory. This makes it easy when generating
# a new baseline or updating it.

import argparse
import os
import sys
import subprocess
import glob
from distutils.dir_util import copy_tree
from lib import git
from shutil import rmtree

oscheck_ansible_python_dir = os.path.dirname(os.path.abspath(__file__))
top_dir = oscheck_ansible_python_dir + "/../../../../"
results_dir = top_dir + "workflows/blktests/results/"
last_run_dir = results_dir + "last-run/"
blktests_last_kernel = top_dir + 'workflows/blktests/results/last-kernel.txt'

def clean_empty_dir(target_results):
    for i in range(1, 3):
        for root, dirs, all_files in os.walk(target_results):
            for dir in dirs:
                f = os.path.join(root, dir)
                if len(os.listdir(f)) == 0:
                    sys.stdout.write("Pruning %s\n" % f)
                    rmtree(f)
                else:
                    clean_empty_dir(f)

def main():
    parser = argparse.ArgumentParser(description='Get list of expunge files not yet committed in git')
    parser.add_argument('--clean-dir-only', metavar='<clean_dir_only>', type=str, default='none',
                        help='Do not perform an evaluation, just clean empty directories on the specified directory')
    args = parser.parse_args()

    if not os.path.isfile(blktests_last_kernel):
        sys.stdout.write("%s does not exist\n" % blktests_last_kernel)
        sys.exit(1)

    kernel = None
    f = open(blktests_last_kernel, 'r')
    for line in f:
        kernel = line.strip()
    if not line:
        sys.stdout.write("Empty file: %s\n" % blktests_last_kernel)
        sys.exit(1)

    if args.clean_dir_only and args.clean_dir_only != "none":
        sys.stdout.write("cleaning %s\n" % args.clean_dir_only)
        clean_empty_dir(args.clean_dir_only)
        sys.exit(0)

    target_results = results_dir + kernel + '/'
    sys.stdout.write("Copying %s to %s ...\n" % (last_run_dir, target_results))
    copy_tree(last_run_dir, target_results)

    for root, dirs, all_files in os.walk(target_results):
        for fname in all_files:
            f = os.path.join(root, fname)
            if os.path.isdir(f):
                continue
            if not os.path.isfile(f):
                continue
            test_name_list = f.split(target_results)
            if len(test_name_list) < 1:
                continue
            test_name_full = test_name_list[1]
            test_name_full_list = test_name_full.split("/")
            if len(test_name_full_list) != 3:
                continue
            bdev = test_name_full_list[0]
            group = test_name_full_list[1]
            test_name_file = test_name_full_list[2]
            test_name = ""
            test_name_file_list = test_name_file.split(".")
            if len(test_name_file_list) == 0:
                test_name = test_name_file
            else:
                test_name = test_name_file_list[0]

            test_dir = os.path.dirname(f)
            name_lookup_base = test_dir + '/' + test_name + '*'
            name_lookup = test_dir + '/' + test_name + '.*'
            listing = glob.glob(name_lookup)
            bad_ext_found = False
            if len(listing) > 0:
                for ext_file in listing:
                    if ext_file.endswith(".dmesg") or ext_file.endswith(".bad"):
                        bad_ext_found = True
            if not bad_ext_found:
                for r in glob.glob(name_lookup_base):
                    os.unlink(r)
    clean_empty_dir(target_results)

if __name__ == '__main__':
    main()
