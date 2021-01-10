#!/usr/bin/python3
# SPDX-License-Identifier: GPL-2.0

# Augment expunge list based on results directory
#
# Given a directory path it finds all test failures and augments your
# existing expunge list you can use with oscheck. If a failure was
# present it will not be added again. If you had no expunge files,
# they will be created for you.

import argparse
import os
import sys
import subprocess

oscheck_ansible_python_dir = os.path.dirname(os.path.abspath(__file__))
oscheck_sort_expunge = oscheck_ansible_python_dir + "/../../../scripts/workflows/fstests/sort-expunges.sh"

def append_line(output_file, test_failure_line):
    # We want to now add entries like generic/xxx where xxx are digits
    output = open(output_file, "a+")
    output.write("%s\n" % test_failure_line)
    output.close()

def main():
    parser = argparse.ArgumentParser(description='Augments expunge list for oscheck')
    parser.add_argument('filesystem', metavar='<filesystem name>', type=str,
                        help='filesystem which was tested')
    parser.add_argument('results', metavar='<directory with results>', type=str,
                        help='directory with results file')
    parser.add_argument('outputdir', metavar='<output directory>', type=str,
                        help='The directory where to generate the expunge lists to')
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
            if not f.endswith('.bad'):
                continue

            # f may be results/oscheck-xfs/4.19.0-4-amd64/xfs/generic/xxx.out.bad
            # where xxx are digits
            bad_file_list = f.split("/")
            bad_file_list_len = len(bad_file_list) - 1
            bad_file = bad_file_list[bad_file_list_len]
            test_type = bad_file_list[bad_file_list_len-1]
            section = bad_file_list[bad_file_list_len-2]
            kernel = bad_file_list[bad_file_list_len-3]
            hostname = bad_file_list[bad_file_list_len-4]

            bad_file_parts = bad_file.split(".")
            bad_file_part_len = len(bad_file_parts) - 1
            bad_file_test_number = bad_file_parts[bad_file_part_len - 2]
            # This is like for example generic/xxx where xxx are digits
            test_failure_line = test_type + '/' + bad_file_test_number

            # now to stuff this into expunge files such as:
            # path/4.19.17/xfs/unassigned/xfs_nocrc.txt
            expunge_kernel_dir = args.outputdir + '/' + kernel + '/' + args.filesystem + '/'
            output_dir = expunge_kernel_dir + 'unassigned/'
            output_file = output_dir + section + '.txt'
            shortcut_kernel_dir = None
            shortcut_dir = None
            shortcut_file = None

            if hostname.startswith("sles"):
                ksplit = kernel.split(".")
                shortcut_kernel = ksplit[0] + "." + ksplit[1] + "." + ksplit[2]
                shortcut_kernel_dir = args.outputdir + '/' + shortcut_kernel + '/' + args.filesystem + '/'
                shortcut_dir = shortcut_kernel_dir + 'unassigned/'
                shortcut_file = shortcut_dir + section + '.txt'

            if not os.path.isdir(output_dir):
                if shortcut_dir and os.path.isdir(shortcut_dir):
                    output_dir = shortcut_dir
                    output_file = shortcut_file
                    expunge_kernel_dir = shortcut_kernel_dir
                else:
                    os.makedirs(output_dir)

            if not os.path.isfile(output_file):
                sys.stdout.write("%s %s new failure found file was empty\n" % (section, test_failure_line))
                append_line(output_file, test_failure_line)
            else:
                existing_file = open(output_file, 'r')
                all_lines = existing_file.readlines()
                existing_file.close()
                found = False
                for line in all_lines:
                    if test_failure_line in line:
                        found = True
                        break
                if not found:
                    sys.stdout.write("%s %s new failure found\n" % (section, test_failure_line))
                    append_line(output_file, test_failure_line)

    if expunge_kernel_dir != "":
        sys.stdout.write("Sorting %s ...\n" % (expunge_kernel_dir))
        sys.stdout.write("Running %s %s...\n" % (oscheck_sort_expunge, expunge_kernel_dir))
        subprocess.call([oscheck_sort_expunge, expunge_kernel_dir])

if __name__ == '__main__':
    main()
