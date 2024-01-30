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
from lib import systemd_remote
import sys, os, grp
import configparser
import argparse
from itertools import chain

def print_fstest_host_status(host, verbose, use_remote, use_ssh, basedir, config):
    if "CONFIG_DEVCONFIG_ENABLE_SYSTEMD_JOURNAL_REMOTE" in config and not use_ssh:
        remote_path = "/var/log/journal/remote/"
        kernel = systemd_remote.get_uname(remote_path, host)
        if kernel is None:
            sys.stderr.write("No kernel could be identified for host: %s\n" % host)
            sys.exit(1)
    else:
        kernel = kssh.get_uname(host).rstrip()
    section = fstests.get_section(host, config)
    (last_test, last_test_time, current_time_str, delta_seconds, stall_suspect) = fstests.get_fstest_host(use_remote, use_ssh, host, basedir, kernel, section, config)
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
        soak_duration_seconds = 0
        if "CONFIG_FSTESTS_SOAK_DURATION" in config:
            soak_duration_seconds = config["CONFIG_FSTESTS_SOAK_DURATION"].strip('\"')
            soak_duration_seconds = int(soak_duration_seconds)
        uses_soak = fstests.fstests_test_uses_soak_duration(last_test)
        is_soaking = uses_soak and soak_duration_seconds != 0
        soaking_str = ""
        if is_soaking:
            soaking_str = "(soak)"
        percent_done_str = "%.0f%% %s" % (percent_done, soaking_str)
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
    parser.add_argument('--use-systemd-remote', const=True, default=True, action="store_const",
                        help='Use use systemd-remote uploaded journals if available')
    parser.add_argument('--use-ssh', const=True, default=False, action="store_const",
                        help='Force to only use use ssh for journals.')
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

    remote_group = "systemd-journal-remote"

    if "CONFIG_DEVCONFIG_ENABLE_SYSTEMD_JOURNAL_REMOTE" in config and not args.use_ssh:
        group = grp.getgrnam(remote_group)
        if group is not None:
            remote_gid = group[2]
            if remote_gid not in os.getgrouplist(os.getlogin(), os.getgid()):
                sys.stderr.write("Your username is not part of the group %s\n" %
                                 remote_group)
                sys.stderr.write("Fix this and try again")
                sys.exit(1)
        else:
                sys.stderr.write("The group %s was not found, add Kconfig support for the systemd-remote-journal group used" % remote_group)
                sys.exit(1)

    hosts = fstests.get_hosts(args.hostfile, args.hostsection)
    sys.stdout.write("%35s%20s%20s%20s%20s%15s%30s\n" % ("Hostname", "Test-name", "Completion %", "runtime(s)", "last-runtime(s)", "Stall-status", "Kernel"))
    for h in hosts:
        print_fstest_host_status(h, args.verbose,
                                 args.use_systemd_remote,
                                 args.use_ssh,
                                 basedir,
                                 config)
    soak_duration_seconds = 0
    if "CONFIG_FSTESTS_SOAK_DURATION" in config:
        soak_duration_seconds = config["CONFIG_FSTESTS_SOAK_DURATION"].strip('\"')
        soak_duration_seconds = int(soak_duration_seconds)

    journal_method = "ssh"
    if "CONFIG_DEVCONFIG_ENABLE_SYSTEMD_JOURNAL_REMOTE" in config and not args.use_ssh:
        journal_method = "systemd-journal-remote"

    sys.stdout.write("\n%25s%20s\n" % ("Journal-method", "Soak-duration(s)"))
    sys.stdout.write("%25s%20d\n" % (journal_method, soak_duration_seconds))

if __name__ == '__main__':
    ret = _main()
