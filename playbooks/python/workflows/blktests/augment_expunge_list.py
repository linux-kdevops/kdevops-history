#!/usr/bin/python3
# SPDX-License-Identifier: copyleft-next-0.3.1

# Augment expunge list based on results directory for blktests
#
# Given a directory path it finds all test failures and augments your
# existing expunge list. If a failure was present it will not be added again.
# If you had no expunge files, they will be created for you.

import argparse
import os
import sys
import subprocess
import configparser
from itertools import chain

oscheck_ansible_python_dir = os.path.dirname(os.path.abspath(__file__))
oscheck_sort_expunge = oscheck_ansible_python_dir + "/../../../scripts/workflows/fstests/sort-expunges.sh"
top_dir = oscheck_ansible_python_dir + "/../../../../"
blktests_last_kernel = top_dir + 'workflows/blktests/results/last-kernel.txt'
expunge_name = "failures.txt"

def append_line(output_file, test_failure_line):
    # We want to now add entries like block/xxx where xxx are digits
    output = open(output_file, "a+")
    output.write("%s\n" % test_failure_line)
    output.close()

def is_config_bool_true(config, name):
    if name in config and config[name].strip('\"') == "y":
        return True
    return False

def config_string(config, name):
    if name in config:
        return config[name].strip('\"')
    return None

def get_config(dotconfig):
    config = configparser.ConfigParser(allow_no_value=True, strict=False, interpolation=None)
    with open(dotconfig) as lines:
        lines = chain(("[top]",), lines)
        config.read_file(lines)
        return config["top"]
    return None

def read_blktest_last_kernel():
    if not os.path.isfile(blktests_last_kernel):
        return None
    kfile = open(blktests_last_kernel, 'r')
    all_lines = kfile.readlines()
    kfile.close()
    for line in all_lines:
        return line.strip()
    return None

def main():
    parser = argparse.ArgumentParser(description='Augments expunge list for blktest')
    parser.add_argument('results', metavar='<directory with results>', type=str,
                        help='directory with results file')
    parser.add_argument('outputdir', metavar='<output directory>', type=str,
                        help='The directory where to generate the expunge failure.txt ')
    parser.add_argument('--verbose', const=True, default=False, action="store_const",
                        help='Print more verbose information')
    args = parser.parse_args()

    expunge_kernel_dir = ""

    dotconfig = top_dir + '/.config'
    config = get_config(dotconfig)
    if not config:
        sys.stdout.write("%s does not exist\n" % (dotconfig))
        sys.exit(1)

    kernel = read_blktest_last_kernel()
    if not kernel:
        sys.stdout.write("%s does not exist\n" % (blktests_last_kernel))
        sys.exit(1)

    bad_files = []
    for root, dirs, all_files in os.walk(args.results):
        for fname in all_files:
            f = os.path.join(root, fname)
            if os.path.isdir(f):
                continue
            if not os.path.isfile(f):
                continue
            if not f.endswith('.bad') and not f.endswith('.dmesg'):
                continue

            bad_files.append(f)
    for f in bad_files:
        if args.verbose:
            sys.stdout.write("Processing %s\n" % f)

        # f may be results/last-run/nodev/meta/006.out.bad
        # f may be results/last-run/nodev/meta/009.dmesg
        bad_file_list = f.split("/")
        bad_file_list_len = len(bad_file_list) - 1
        bad_file =      bad_file_list[bad_file_list_len]
        test_group =    bad_file_list[bad_file_list_len-1]
        bdev =          bad_file_list[bad_file_list_len-2]

        if args.verbose:
            sys.stdout.write("%s\n" % bad_file_list)
            sys.stdout.write("\tbad_file: %s\n" %bad_file)
            sys.stdout.write("\ttest_group: %s\n" % test_group)
            sys.stdout.write("\tkernel: %s\n" % kernel)

        bad_file_parts = bad_file.split(".")
        bad_file_part_len = len(bad_file_parts) - 1

        bad_file_test_number = None
        test_failure_line = None

        if bad_file_part_len == 0 or bad_file_part_len > 2:
            sys.stdout.write("Unexpected bad file length: %s\n" % bad_file)
            sys.exit(1)

        if bad_file.endswith(".out.bad"):
            bad_file_test_number = bad_file_parts[bad_file_part_len - 2]
        elif bad_file.endswith(".dmesg"):
            bad_file_test_number = bad_file_parts[bad_file_part_len - 1]
        else:
            sys.stdout.write("Unexpected bad file: %s\n" % bad_file)
            sys.exit(1)

        # This is like for example block/xxx where xxx are digits
        test_failure_line = test_group + '/' + bad_file_test_number

        # now to stuff this into expunge files such as:
        # expunges/sles/15.3/failures.txt
        expunge_kernel_dir = args.outputdir + '/' + kernel + '/'
        output_dir = expunge_kernel_dir
        output_file = output_dir + expunge_name
        shortcut_kernel_dir = None
        shortcut_dir = None
        shortcut_file = None

        if is_config_bool_true(config, "CONFIG_VAGRANT_SUSE"):
            # If kotd is enabled we assume you have the latest kernel and
            # all new results are relevant to that release.
            if is_config_bool_true(config, "CONFIG_WORKFLOW_KOTD_ENABLE"):
                sles_release_name = config_string(config, "CONFIG_KDEVOPS_HOSTS_PREFIX")
                sles_release_parts = sles_release_name.split("sp")
                if len(sles_release_parts) <= 1:
                    sys.stderr.write("Unexpected sles_release_name: %s\n" % sles_release_name)
                    sys.exit(1)
                sles_point_release = sles_release_parts[0].split("sles")[1] + "." + sles_release_parts[1]

                # This becomes generic release directory, not specific to any
                # kernel.
                shortcut_dir = args.outputdir + '/' + "sles/" + sles_point_release + '/'
                shortcut_kernel_dir = shortcut_dir
                shortcut_file = shortcut_dir + expunge_name
            else:
                ksplit = kernel.split(".")
                shortcut_kernel = ksplit[0] + "." + ksplit[1] + "." + ksplit[2]
                shortcut_kernel_dir = args.outputdir + '/' + shortcut_kernel + '/'
                shortcut_dir = shortcut_kernel_dir
                shortcut_file = shortcut_dir + expunge_name

        if not os.path.isdir(output_dir):
            if shortcut_dir and os.path.isdir(shortcut_dir):
                output_dir = shortcut_dir
                output_file = shortcut_file
                expunge_kernel_dir = shortcut_kernel_dir
            else:
                os.makedirs(output_dir)

        if not os.path.isfile(output_file):
            sys.stdout.write("====%s/%s new failure found file was empty\n" % (test_group, test_failure_line))
            append_line(output_file, test_failure_line)
        else:
            existing_file = open(output_file, 'r')
            all_lines = existing_file.readlines()
            existing_file.close()
            found = False
            for line in all_lines:
                if test_failure_line.strip() in line.strip():
                    found = True
                    break
            if not found:
                sys.stdout.write("%s %s new failure found\n" % (test_group, test_failure_line))
                append_line(output_file, test_failure_line)

    if expunge_kernel_dir != "":
        sys.stdout.write("Sorting %s ...\n" % (expunge_kernel_dir))
        sys.stdout.write("Running %s %s...\n" % (oscheck_sort_expunge, expunge_kernel_dir))
        subprocess.call([oscheck_sort_expunge, expunge_kernel_dir])

if __name__ == '__main__':
    main()
