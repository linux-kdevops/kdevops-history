#!/usr/bin/python3
# SPDX-License-Identifier: copyleft-next-0.3.1

# fstests test watchdog for kdevops
#
# Example usage:
#
# ./fstests_watchdog.py kdevops/hosts all

from datetime import datetime
from lib import kssh
from lib import fstests
import sys, os
import configparser
import argparse
from itertools import chain

def print_fstest_host_status(host, verbose, basedir, config):
    kernel = kssh.get_uname(host).rstrip()
    section = fstests.get_section(host, config)
    (last_test, last_test_time, current_time_str, delta_seconds, stall_suspect) = fstests.get_fstest_host(host, basedir, kernel, section, config)
    checktime =  fstests.get_checktime(host, basedir, kernel, section, last_test)

    percent_done = 0
    if checktime > 0:
        percent_done = delta_seconds * 100 / checktime

    stall_str = "OK"
    if stall_suspect:
        if kernel == "Timeout" or last_test is None:
            stall_str = "Timeout"
        else:
            stall_str = "Hung-Stalled"

    if last_test is None:
        if verbose:
            sys.stdout.write("Host               : %s\n" % (host))
            sys.stdout.write("Last    test       : None\n")
        else:
            percent_done_str = "%.0f%%" % (0)
            sys.stdout.write("%35s%20s%20s%20s%20s%15s%30s\n" % (host, "None", percent_done_str, 0, 0, stall_str, kernel))
        return

    if not verbose:
        percent_done_str = "%.0f%%" % (percent_done)
        sys.stdout.write("%35s%20s%20s%20s%20s%15s%30s\n" % (host, last_test, percent_done_str, str(delta_seconds), str(checktime), stall_str, kernel))
        return

    sys.stdout.write("Host               : %s\n" % (host))
    sys.stdout.write("Last    test       : %s\n" % (last_test))
    sys.stdout.write("Last    test   time: %s\n" % (last_test_time))
    sys.stdout.write("Current system time: %s\n" % (current_time_str))

    sys.stdout.write("Delta: %d total second\n" % (delta_seconds))
    sys.stdout.write("\t%d minutes\n" % (delta_seconds / 60))
    sys.stdout.write("\t%d seconds\n" % (delta_seconds % 60))
    sys.stdout.write("Timeout-status: ")

    if stall_suspect:
        sys.stdout.write("POSSIBLE-STALL")
    else:
        sys.stdout.write("OK")
    sys.stdout.write("\n")

def _main():
    parser = argparse.ArgumentParser(description='fstest-watchdog')
    parser.add_argument('hostfile', metavar='<ansible hostfile>', type=str,
                        default='hosts',
                        help='Ansible hostfile to use')
    parser.add_argument('hostsection', metavar='<ansible hostsection>', type=str,
                        default='baseline',
                        help='The name of the section to read hosts from')
    parser.add_argument('--verbose', const=True, default=False, action="store_const",
                        help='Be verbose on otput.')
    args = parser.parse_args()

    if not os.path.isfile(args.hostfile):
        sys.stdout.write("%s does not exist\n" % (args.hostfile))
        sys.exit(1)

    dotconfig = os.path.dirname(os.path.abspath(args.hostfile)) + '/.config'
    config = fstests.get_config(dotconfig)
    if not config:
        sys.stdout.write("%s does not exist\n" % (dotconfig))
        sys.exit(1)
    basedir = os.path.dirname(dotconfig)

    hosts = fstests.get_hosts(args.hostfile, args.hostsection)
    sys.stdout.write("%35s%20s%20s%20s%20s%15s%30s\n" % ("Hostname", "Test-name", "Completion %", "runtime(s)", "last-runtime(s)", "Stall-status", "Kernel"))
    for h in hosts:
        print_fstest_host_status(h, args.verbose, basedir, config)

if __name__ == '__main__':
    ret = _main()
