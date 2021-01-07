#!/usr/bin/python3
# SPDX-License-Identifier: GPL-2.0

# fstests test watchdog for kdevops
#
# Example usage:
#
# while true; do ./fstests_watchdog.py kdevops/hosts all; sleep 3; done

from datetime import datetime
from lib import kssh
import sys, os
import configparser
import argparse
from itertools import chain

def get_fstest_host(host, dotconfig, kernel, section):
    stall_suspect = False
    latest_dmesg_fstest_line = kssh.get_last_fstest(host)
    if latest_dmesg_fstest_line is None:
        return (None, None, None, None, False)
    if latest_dmesg_fstest_line == "Timeout":
        return (None, None, None, None, True)

    last_test = latest_dmesg_fstest_line.split("at ")[0]
    last_test = last_test.replace(" ", "")
    last_test_time = latest_dmesg_fstest_line.split("at ")[1].rstrip()
    current_time_str = kssh.get_current_time(host).rstrip()

    fstests_date_str_format = '%Y-%m-%d %H:%M:%S'
    d1 = datetime.strptime(last_test_time, fstests_date_str_format)
    d2 = datetime.strptime(current_time_str, fstests_date_str_format)

    delta = d2 - d1
    delta_seconds = int(delta.total_seconds())

    checktime =  get_checktime(host, dotconfig, kernel, section, last_test)
    # If the time of a test is small, say a second, it may take 5 seconds due to
    # some other system variant issue, so don't take this into account for tests
    # which are fast.
    if checktime > 30:
        # If a test typically takes 30 seconds but its taking 10 times that amount
        # we suspect the system crashed.
        suspect_crash_time_seconds = checktime * 10
    elif checktime == 0:
        # 10 minutes, I'm not aware of a test which takes more than 10 minutes
        suspect_crash_time_seconds = 60 * 10
    else:
        # If a test typically takes between 1 second to 30 seconds we can likely
        # safely assume the system has crashed after 5 minutes
        suspect_crash_time_seconds = 60 * 5

    if delta_seconds >= suspect_crash_time_seconds and not 'fstestsstart/000' in last_test and 'fstestsstart/000' not in last_test:
        stall_suspect = True

    return (last_test, last_test_time, current_time_str, delta_seconds, stall_suspect)

def get_checktime(host, dotfile, kernel, section, last_test):
    basedir = os.path.dirname(dotfile)
    checktime_dir = basedir + '/workflows/fstests/results/' + host + '/' + kernel + '/' + section + '/'
    checktime_file = checktime_dir + 'check.time'
    if not os.path.isfile(checktime_file):
        return 0
    cp = open(checktime_file, 'r')
    for line in cp:
        elems = line.rstrip().split(" ")
        this_test = elems[0].rstrip().replace(" ", "")
        if this_test == last_test:
            return int(elems[1])
    return 0

def get_section(host, dotconfig):
    config = configparser.ConfigParser(allow_no_value=True, strict=False, interpolation=None)
    with open(dotconfig) as lines:
        lines = chain(("[top]",), lines)
        config.read_file(lines)
        hostprefix = config["top"]["CONFIG_KDEVOPS_HOSTS_PREFIX"].strip('\"')
        return host.split(hostprefix + "-")[1].replace("-", "_")

def print_fstest_host_status(host, verbose, html, dotconfig):
    kernel = kssh.get_uname(host).rstrip()
    section = get_section(host, dotconfig)
    (last_test, last_test_time, current_time_str, delta_seconds, stall_suspect) = get_fstest_host(host, dotconfig, kernel, section)
    checktime =  get_checktime(host, dotconfig, kernel, section, last_test)

    percent_done = 0
    if checktime > 0:
        percent_done = delta_seconds * 100 / checktime

    stall_str = "OK"
    if stall_suspect:
        if kernel == "Timeout":
            stall_str = "Timeout"
        else:
            stall_str = "OK"

    if last_test is None:
        if verbose:
            sys.stdout.write("Host               : %s\n" % (host))
            sys.stdout.write("Last    test       : None\n")
        else:
            if not html:
                sys.stdout.write("%35s\t%20s\t%.0f%%\t%d\t%d\t%15s\t%s\n" % (host, "None", 0, 0, 0, stall_str, kernel))
            else:
                sys.stdout.write("<tr>")
                sys.stdout.write("<td>%s</td>" %(host))
                sys.stdout.write("<td>None</td>")
                sys.stdout.write("<td>0</td>")
                sys.stdout.write("<td>OK</td>")
                sys.stdout.write("</tr>")
        return

    if not verbose:
        if not html:
            sys.stdout.write("%35s\t%20s\t%.0f%%\t%d\t%d\t%15s\t%s\n" % (host, last_test, percent_done, delta_seconds, checktime, stall_str, kernel))
        else:
                sys.stdout.write("<tr>")
                sys.stdout.write("<td>%s</td>" % (host))
                sys.stdout.write("<td>%s</td>" % (last_test))
                sys.stdout.write("<td>%d</td>" % (delta_seconds))
                sys.stdout.write("<td>%s</td>" % (stall_str))
                sys.stdout.write("</tr>")
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

def get_hosts(hostfile, hostsection):
    hosts = []
    config = configparser.ConfigParser(allow_no_value=True, strict=False, interpolation=None)
    config.read(hostfile)
    if hostsection not in config:
        return hosts
    for key in config[hostsection]:
        hosts.append(key)
    return hosts

def _main():
    parser = argparse.ArgumentParser(description='fstest-watchdog')
    parser.add_argument('hostfile', metavar='<ansible hostfile>', type=str,
                        default='hosts',
                        help='Ansible hostfile to use')
    parser.add_argument('hostsection', metavar='<ansible hostsection>', type=str,
                        default='baseline',
                        help='The name of the section to read hosts from')
    parser.add_argument('--html', const=True, default=False, action="store_const",
                        help='Provide output in html format')
    parser.add_argument('--verbose', const=True, default=False, action="store_const",
                        help='Be verbose on otput. This only applies to non-html output')
    args = parser.parse_args()

    if not os.path.isfile(args.hostfile):
        sys.stdout.write("%s does not exist\n" % (args.hostfile))
        sys.exit(1)

    dotconfig = os.path.dirname(args.hostfile) + '/.config'
    hosts = get_hosts(args.hostfile, args.hostsection)
    for h in hosts:
        print_fstest_host_status(h, args.verbose, args.html, dotconfig)

if __name__ == '__main__':
    ret = _main()
