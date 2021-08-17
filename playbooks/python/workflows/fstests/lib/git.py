# SPDX-License-Identifier: copyleft-next-0.3.1

import subprocess, os

class GitError(Exception):
    pass
class ExecutionError(GitError):
    def __init__(self, errcode):
        self.error_code = errcode
class TimeoutExpired(GitError):
    def __init__(self, errcode):
        self.error_code = errcode
        return "timeout"

def _check(process):
    if process.returncode != 0:
        raise ExecutionError(process.returncode)

def is_new_file(file):
    cmd = ['git', 'status', '-s', file ]
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
            return False
        if stdout.startswith('??'):
            return True
        return False
