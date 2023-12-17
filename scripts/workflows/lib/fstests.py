# SPDX-License-Identifier: copyleft-next-0.3.1
from datetime import datetime
from lib import kssh
from lib import systemd_remote
import sys, os
import configparser
import argparse
from itertools import chain

class FstestsError(Exception):
    pass

def fstests_check_pid(host):
    pid = kssh.first_process_name_pid(host, "check")
    if pid <= 0:
        return pid
    dir = "/proc/" + str(pid)  + "/cwd/tests"
    if kssh.dir_exists(host, dir):
        return pid
    return 0

# Later on we can automate this list with a git grep on the fstests
# tests/ directory, and we inject this here.
def fstests_test_uses_soak_duration(testname):
    USES_SOAK_DURATION = [ "generic/019" ]
    USES_SOAK_DURATION += [ "generic/388" ]
    USES_SOAK_DURATION += [ "generic/475" ]
    USES_SOAK_DURATION += [ "generic/476" ]
    USES_SOAK_DURATION += [ "generic/521" ]
    USES_SOAK_DURATION += [ "generic/522" ]
    USES_SOAK_DURATION += [ "generic/616" ]
    USES_SOAK_DURATION += [ "generic/617" ]
    USES_SOAK_DURATION += [ "generic/642" ]
    USES_SOAK_DURATION += [ "generic/650" ]
    USES_SOAK_DURATION += [ "generic/648" ]
    USES_SOAK_DURATION += [ "xfs/285" ]
    USES_SOAK_DURATION += [ "xfs/517" ]
    USES_SOAK_DURATION += [ "xfs/560" ]
    USES_SOAK_DURATION += [ "xfs/561" ]
    USES_SOAK_DURATION += [ "xfs/562" ]
    USES_SOAK_DURATION += [ "xfs/565" ]
    USES_SOAK_DURATION += [ "xfs/570" ]
    USES_SOAK_DURATION += [ "xfs/571" ]
    USES_SOAK_DURATION += [ "xfs/572" ]
    USES_SOAK_DURATION += [ "xfs/573" ]
    USES_SOAK_DURATION += [ "xfs/574" ]
    USES_SOAK_DURATION += [ "xfs/575" ]
    USES_SOAK_DURATION += [ "xfs/576" ]
    USES_SOAK_DURATION += [ "xfs/577" ]
    USES_SOAK_DURATION += [ "xfs/578" ]
    USES_SOAK_DURATION += [ "xfs/579" ]
    USES_SOAK_DURATION += [ "xfs/580" ]
    USES_SOAK_DURATION += [ "xfs/581" ]
    USES_SOAK_DURATION += [ "xfs/582" ]
    USES_SOAK_DURATION += [ "xfs/583" ]
    USES_SOAK_DURATION += [ "xfs/584" ]
    USES_SOAK_DURATION += [ "xfs/585" ]
    USES_SOAK_DURATION += [ "xfs/586" ]
    USES_SOAK_DURATION += [ "xfs/587" ]
    USES_SOAK_DURATION += [ "xfs/588" ]
    USES_SOAK_DURATION += [ "xfs/589" ]
    USES_SOAK_DURATION += [ "xfs/590" ]
    USES_SOAK_DURATION += [ "xfs/591" ]
    USES_SOAK_DURATION += [ "xfs/592" ]
    USES_SOAK_DURATION += [ "xfs/593" ]
    USES_SOAK_DURATION += [ "xfs/594" ]
    USES_SOAK_DURATION += [ "xfs/595" ]
    USES_SOAK_DURATION += [ "xfs/727" ]
    USES_SOAK_DURATION += [ "xfs/729" ]
    USES_SOAK_DURATION += [ "xfs/800" ]
    if testname in USES_SOAK_DURATION:
        return True
    return False

def get_fstest_host(use_remote, use_ssh, host, basedir, kernel, section, config):
    stall_suspect = False
    force_ssh = False
    if kernel == "Uname-issue":
        return (None, None, None, None, True)

    if "CONFIG_DEVCONFIG_ENABLE_SYSTEMD_JOURNAL_REMOTE" not in config:
        force_ssh = True
    if use_ssh:
        force_ssh = True

    if force_ssh:
        latest_dmesg_fstest_line = kssh.get_last_fstest(host)
    else:
        remote_path = "/var/log/journal/remote/"
        latest_dmesg_fstest_line = systemd_remote.get_last_fstest(remote_path, host)
    if latest_dmesg_fstest_line is None:
        return (None, None, None, None, False)
    if latest_dmesg_fstest_line == "Timeout":
        return (None, None, None, None, True)
    check_pid = fstests_check_pid(host)
    if check_pid < 0:
        return (None, None, None, None, True)
    elif check_pid == 0:
        return (None, None, None, None, False)

    last_test = latest_dmesg_fstest_line.split("at ")[0]
    last_test = last_test.replace(" ", "")
    last_test_time = latest_dmesg_fstest_line.split("at ")[1].rstrip()
    current_time_str = kssh.get_current_time(host).rstrip()

    fstests_date_str_format = '%Y-%m-%d %H:%M:%S'
    d1 = datetime.strptime(last_test_time, fstests_date_str_format)
    d2 = datetime.strptime(current_time_str, fstests_date_str_format)

    delta = d2 - d1
    delta_seconds = int(delta.total_seconds())

    soak_duration_seconds = 0
    if "CONFIG_FSTESTS_SOAK_DURATION" in config:
        soak_duration_seconds = config["CONFIG_FSTESTS_SOAK_DURATION"].strip('\"')
        soak_duration_seconds = int(soak_duration_seconds)

    if "CONFIG_FSTESTS_WATCHDOG" not in config:
        enable_watchdog = False
    else:
        enable_watchdog = config["CONFIG_FSTESTS_WATCHDOG"].strip('\"')

    if enable_watchdog:
        max_new_test_time = config["CONFIG_FSTESTS_WATCHDOG_MAX_NEW_TEST_TIME"].strip('\"')
        max_new_test_time = int(max_new_test_time)
        if not max_new_test_time:
            max_new_test_time = 60

        hung_multiplier_long_tests = config["CONFIG_FSTESTS_WATCHDOG_HUNG_MULTIPLIER_LONG_TESTS"].strip('\"')
        hung_multiplier_long_tests = int(hung_multiplier_long_tests)
        if not hung_multiplier_long_tests:
            hung_multiplier_long_tests = 10

        hung_fast_test_max_time = config["CONFIG_FSTESTS_WATCHDOG_HUNG_FAST_TEST_MAX_TIME"].strip('\"')
        hung_fast_test_max_time = int(hung_fast_test_max_time)
        if not hung_fast_test_max_time:
            hung_fast_test_max_time = 5

        checktime =  get_checktime(host, basedir, kernel, section, last_test)

        # If no known prior run time test is known we use a max. This only
        # applies to the first run.
        suspect_crash_time_seconds = 60 * max_new_test_time

        # If the time of a test is small, say a second, it may take 5 seconds due to
        # some other system variant issue, so don't take this into account for tests
        # which are fast.
        if checktime > 30:
            # If the multiplier is 10, if a test typically takes 30 seconds but
            # its taking 10 times that amount we suspect the system crashed.
            suspect_crash_time_seconds = checktime * hung_multiplier_long_tests
        # If a test typically takes between 1 second to 30 seconds we can likely
        # safely assume the system has crashed after hung_fast_test_max_time
        # minutes
        elif checktime >  0:
            suspect_crash_time_seconds = 60 * hung_fast_test_max_time

        if fstests_test_uses_soak_duration(last_test):
            suspect_crash_time_seconds += soak_duration_seconds

        if delta_seconds >= suspect_crash_time_seconds and 'fstestsstart/000' not in last_test and 'fstestsend/000' not in last_test:
            stall_suspect = True

    return (last_test, last_test_time, current_time_str, delta_seconds, stall_suspect)

def get_checktime(host, basedir, kernel, section, last_test):
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

def get_config(dotconfig):
    config = configparser.ConfigParser(allow_no_value=True, strict=False, interpolation=None)
    with open(dotconfig) as lines:
        lines = chain(("[top]",), lines)
        config.read_file(lines)
        return config["top"]
    return None

def get_section(host, config):
    hostprefix = config["CONFIG_KDEVOPS_HOSTS_PREFIX"].strip('\"')
    return host.split(hostprefix + "-")[1].replace("-", "_")

def get_hosts(hostfile, hostsection):
    hosts = []
    config = configparser.ConfigParser(allow_no_value=True, strict=False, interpolation=None)
    config.read(hostfile)
    if hostsection not in config:
        return hosts
    for key in config[hostsection]:
        hosts.append(key)
    return hosts
