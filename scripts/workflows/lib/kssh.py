# SPDX-License-Identifier: copyleft-next-0.3.1

import subprocess, os

class KsshError(Exception):
    pass
class ExecutionError(KsshError):
    def __init__(self, errcode):
        self.error_code = errcode
class TimeoutExpired(KsshError):
    def __init__(self, errcode):
        self.error_code = errcode
        return "timeout"

def _check(process):
    if process.returncode != 0:
        raise ExecutionError(process.returncode)

def dir_exists(host, dirname):
    cmd = ['ssh', host,
           'sudo',
           'ls', '-ld',
           dirname ]
    process = subprocess.Popen(cmd,
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                               close_fds=True, universal_newlines=True)
    data = None
    try:
        data = process.communicate(timeout=60)
    except subprocess.TimeoutExpired:
        return False
    else:
        stdout = data[0]
        process.wait()
        if process.returncode == 0:
            return True
        else:
            return False

def first_process_name_pid(host, process_name):
    cmd = ['ssh', host,
           'sudo',
           'ps', '-ef',
           '|', 'grep', '-v', 'grep',
           '|', 'grep', process_name,
           '|', 'awk', '\'{print $2}\'',
           '|', 'tail', '-1' ]
    process = subprocess.Popen(cmd,
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                               close_fds=True, universal_newlines=True)
    data = None
    try:
        data = process.communicate(timeout=60)
    except subprocess.TimeoutExpired:
        return -1
    else:
        stdout = data[0]
        process.wait()
        if process.returncode != 0:
            return -1
        if stdout == "":
            return 0
        return int(stdout)

def get_uname(host):
    cmd = ['ssh', host, 'uname', '-r' ]
    process = subprocess.Popen(cmd,
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                               close_fds=True, universal_newlines=True)
    data = None
    try:
        data = process.communicate(timeout=60)
    except subprocess.TimeoutExpired:
        return "Timeout"
    else:
        stdout = data[0]
        process.wait()
        if process.returncode != 0:
            return "Uname-issue"
        return stdout

def get_test(host, suite):
    if suite not in [ 'fstests', 'blktests']:
        return None
    run_string = "run " + suite
    cmd = ['ssh', host,
           'sudo',
           'dmesg',
           '|', 'grep', '"' + run_string + '"',
           '|', 'awk', '-F"' + run_string + ' "', '\'{print $2}\'',
           '|', 'tail', '-1' ]
    process = subprocess.Popen(cmd,
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                               close_fds=True, universal_newlines=True)
    data = None
    try:
        data = process.communicate(timeout=60)
    except subprocess.TimeoutExpired:
        return "Timeout"
    else:
        stdout = data[0]
        process.wait()
        if process.returncode != 0:
            return None
        if "at " not in stdout:
            return None

        if len(stdout.split("at ")) <= 1:
            return None

        return stdout

def get_last_fstest(host):
    return get_test(host, 'fstests')

def get_last_blktest(host):
    return get_test(host, 'blktests')

def get_current_time(host):
    cmd = ['ssh', host,
           'date', '--rfc-3339=\'seconds\'',
           '|', 'awk', '-F"+"', '\'{print $1}\'' ]
    process = subprocess.Popen(cmd,
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                               close_fds=True, universal_newlines=True)
    data = None
    try:
        data = process.communicate(timeout=60)
    except subprocess.TimeoutExpired:
        return "Timeout"
    else:
        stdout = data[0]
        process.wait()
        if process.returncode != 0:
            return "Timeout"

        return stdout
