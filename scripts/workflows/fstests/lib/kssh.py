# SPDX-License-Identifier: GPL-2.0

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

def get_uname(host):
    cmd = ['ssh', host, 'uname', '-r' ]
    process = subprocess.Popen(cmd,
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                               close_fds=True, universal_newlines=True)
    data = None
    try:
        data = process.communicate(timeout=1)
    except subprocess.TimeoutExpired:
        return "Timeout"
    else:
        stdout = data[0]
        process.wait()
        if process.returncode != 0:
            return "Uname-issue"
        return stdout

def get_last_fstest(host):
    cmd = ['ssh', host,
           'sudo',
           'journalctl', '-k',
           '|', 'grep', '"run fstests"',
           '|', 'awk', '-F"run fstests "', '\'{print $2}\'',
           '|', 'tail', '-1' ]
    process = subprocess.Popen(cmd,
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                               close_fds=True, universal_newlines=True)
    data = None
    try:
        data = process.communicate(timeout=1)
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

def get_current_time(host):
    cmd = ['ssh', host,
           'date', '--rfc-3339=\'seconds\'',
           '|', 'awk', '-F"+"', '\'{print $1}\'' ]
    process = subprocess.Popen(cmd,
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                               close_fds=True, universal_newlines=True)
    data = None
    try:
        data = process.communicate(timeout=1)
    except subprocess.TimeoutExpired:
        return "Timeout"
    else:
        stdout = data[0]
        process.wait()
        if process.returncode != 0:
            return "Timeout"

        return stdout
