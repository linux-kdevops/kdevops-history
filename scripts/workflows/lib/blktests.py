# SPDX-License-Identifier: copyleft-next-0.3.1
from datetime import datetime
from lib import kssh
import sys, os
import configparser
import argparse
import re
from itertools import chain

class BlktestsError(Exception):
    pass

def blktests_check_pid(host):
    pid = kssh.first_process_name_pid(host, "check")
    if pid <= 0:
        return pid
    dir = "/proc/" + str(pid)  + "/cwd/tests"
    if kssh.dir_exists(host, dir):
        return pid
    return 0

def get_blktest_host(host, basedir, kernel, section, config):
    stall_suspect = False
    if kernel == "Uname-issue":
        return (None, None, None, None, True)
    latest_dmesg_blktest_line = kssh.get_last_blktest(host)
    if latest_dmesg_blktest_line is None:
        return (None, None, None, None, False)
    if latest_dmesg_blktest_line == "Timeout":
        return (None, None, None, None, True)
    check_pid = blktests_check_pid(host)
    if check_pid < 0:
        return (None, None, None, None, True)
    elif check_pid == 0:
        return (None, None, None, None, False)

    last_test = latest_dmesg_blktest_line.split("at ")[0]
    last_test = last_test.replace(" ", "")
    last_test_time = latest_dmesg_blktest_line.split("at ")[1].rstrip()
    current_time_str = kssh.get_current_time(host).rstrip()

    blktests_date_str_format = '%Y-%m-%d %H:%M:%S'
    d1 = datetime.strptime(last_test_time, blktests_date_str_format)
    d2 = datetime.strptime(current_time_str, blktests_date_str_format)

    delta = d2 - d1
    delta_seconds = int(delta.total_seconds())

    if "CONFIG_BLKTESTS_WATCHDOG" not in config:
        enable_watchdog = False
    else:
        enable_watchdog = config["CONFIG_BLKTESTS_WATCHDOG"].strip('\"')

    if enable_watchdog:
        max_new_test_time = config["CONFIG_BLKTESTS_WATCHDOG_MAX_NEW_TEST_TIME"].strip('\"')
        max_new_test_time = int(max_new_test_time)
        if not max_new_test_time:
            max_new_test_time = 60

        hung_multiplier_long_tests = config["CONFIG_BLKTESTS_WATCHDOG_HUNG_MULTIPLIER_LONG_TESTS"].strip('\"')
        hung_multiplier_long_tests = int(hung_multiplier_long_tests)
        if not hung_multiplier_long_tests:
            hung_multiplier_long_tests = 10

        hung_fast_test_max_time = config["CONFIG_BLKTESTS_WATCHDOG_HUNG_FAST_TEST_MAX_TIME"].strip('\"')
        hung_fast_test_max_time = int(hung_fast_test_max_time)
        if not hung_fast_test_max_time:
            hung_fast_test_max_time = 5

        last_run_time_s = get_last_run_time(host, basedir, kernel, section, last_test)

        # If no known prior run time test is known we use a max. This only
        # applies to the first run.
        suspect_crash_time_seconds = 60 * max_new_test_time

        # If the time of a test is small, say a second, it may take 5 seconds due to
        # some other system variant issue, so don't take this into account for tests
        # which are fast.
        if last_run_time_s > 30:
            # If the multiplier is 10, if a test typically takes 30 seconds but
            # its taking 10 times that amount we suspect the system crashed.
            suspect_crash_time_seconds = last_run_time_s * hung_multiplier_long_tests
        # If a test typically takes between 1 second to 30 seconds we can likely
        # safely assume the system has crashed after hung_fast_test_max_time
        # minutes
        elif last_run_time_s >  0:
            suspect_crash_time_seconds = 60 * hung_fast_test_max_time

        if delta_seconds >= suspect_crash_time_seconds and 'blktestsstart/000' not in last_test and 'blktestsend/000' not in last_test:
            stall_suspect = True

    return (last_test, last_test_time, current_time_str, delta_seconds, stall_suspect)

def get_last_run_time(host, basedir, kernel, section, last_test):
    results_dir = basedir + '/workflows/blktests/results/last-run/'
    if not last_test:
        return 0
    if not os.path.isdir(results_dir):
        return 0
    if len(last_test.split("/")) != 2:
        return 0
    last_test_group = last_test.split("/")[0]
    last_test_number = last_test.split("/")[1]
    ok_file = None
    for root, dirs, all_files in os.walk(results_dir):
        for fname in all_files:
            f = os.path.join(root, fname)
            if os.path.isdir(f):
                continue
            if not os.path.isfile(f):
                continue
            search_string = ".*/" + re.escape(last_test) + "$"
            if re.match(search_string, f):
                ok_file = f
                break
    if not ok_file:
        return 0
    f = open(ok_file, 'r')
    for line in f:
        if not "runtime" in line:
            continue
        elems = line.rstrip().split("runtime")
        if len(elems) != 2:
            continue
        time_string = elems[1]
        time_string_elems = time_string.split("s")
        if len(time_string_elems) != 2:
            continue
        return float(time_string_elems[0])
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
