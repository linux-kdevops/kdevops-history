# SPDX-License-Identifier: copyleft-next-0.3.1

import subprocess, os

class SystemdError(Exception):
    pass
class ExecutionError(SystemdError):
    def __init__(self, errcode):
        self.error_code = errcode
class TimeoutExpired(SystemdError):
    def __init__(self, errcode):
        self.error_code = errcode
        return "timeout"

# Returns something like "xfs/040 at 2023-12-17 23:52:14"
def get_test(remote_path, host, suite):
    if suite not in [ 'fstests', 'blktests']:
        return None
    # Example: /var/log/journal/remote/remote-line-xfs-reflink.journal
    fpath = remote_path + "remote-" + host + '.journal'
    run_string = "run " + suite
    cmd = [
           'journalctl',
           '--no-pager',
           '-n 1',
           '-k',
           '-g',
           run_string,
           '--file',
           fpath ]
    process = subprocess.Popen(cmd,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT,
                               close_fds=True,
                               universal_newlines=True)
    data = None
    try:
        data = process.communicate(timeout=120)
    except subprocess.TimeoutExpired:
        return "Timeout"
    else:
        process.wait()
        if process.returncode != 0:
            return None
        last_line = data[0].strip()
        if "at " not in last_line:
            return None
        if len(last_line.split("at ")) <= 1:
            return None
        test_line = last_line.split(run_string)[1].strip()

        return test_line

def get_last_fstest(remote_path, host):
    return get_test(remote_path, host, 'fstests')

def get_last_blktest(remote_path, host):
    return get_test(remote_path, host, 'blktests')
