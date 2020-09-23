#!/usr/bin/python3
# SPDX-License-Identifier: GPL-2.0

import unittest
import re
from filecmp import cmp
import inspect
#from os import remove
from shutil import copyfile
from update_ssh_config import parse_args, run_args

"""
Unit tests for update_ssh_config.py
"""

def get_test_files(function_name):
    test_names = []
    target_sshconfig = 'tests/' + re.sub('^test_', '', function_name)
    test_names.append(target_sshconfig)
    target_sshconfig_orig = target_sshconfig + '.orig'
    test_names.append(target_sshconfig_orig)
    target_sshconfig_copy = target_sshconfig + '.copy'
    test_names.append(target_sshconfig_copy)
    target_sshconfig_res = target_sshconfig + '.res'
    test_names.append(target_sshconfig_res)
    target_sshconfig_bk = target_sshconfig + '.bk'
    test_names.append(target_sshconfig_bk)
    return test_names

class TestUpdateSshConfig(unittest.TestCase):
    def test_0001_remove_hosts_top(self):
        this_function_name = inspect.stack()[0][3]
        tests_names = get_test_files(this_function_name)
        target_sshconfig = tests_names[0]
        target_sshconfig_orig = tests_names[1]
        target_sshconfig_copy = tests_names[2]
        target_sshconfig_res = tests_names[3]
        target_sshconfig_bk = tests_names[4]

        copyfile(target_sshconfig_orig, target_sshconfig_copy)

        args = parse_args([target_sshconfig_copy,
                           '--backup_file',
                           target_sshconfig_bk,
                           '--remove',
                           'kdevops,kdevops-dev'])
        run_args(args)
        self.assertTrue(cmp(target_sshconfig_bk,
                            target_sshconfig_orig, shallow = False))
        self.assertTrue(cmp(target_sshconfig_copy,
                            target_sshconfig_res, shallow = False))
    def test_0002_remove_hosts_middle(self):
        this_function_name = inspect.stack()[0][3]
        tests_names = get_test_files(this_function_name)
        target_sshconfig = tests_names[0]
        target_sshconfig_orig = tests_names[1]
        target_sshconfig_copy = tests_names[2]
        target_sshconfig_res = tests_names[3]
        target_sshconfig_bk = tests_names[4]

        copyfile(target_sshconfig_orig, target_sshconfig_copy)

        args = parse_args([target_sshconfig_copy,
                           '--backup_file',
                           target_sshconfig_bk,
                           '--remove',
                           'kdevops,kdevops-dev'])
        run_args(args)
        self.assertTrue(cmp(target_sshconfig_bk,
                            target_sshconfig_orig, shallow = False))
        self.assertTrue(cmp(target_sshconfig_copy,
                            target_sshconfig_res, shallow = False))
    def test_0003_remove_hosts_bottom(self):
        this_function_name = inspect.stack()[0][3]
        tests_names = get_test_files(this_function_name)
        target_sshconfig = tests_names[0]
        target_sshconfig_orig = tests_names[1]
        target_sshconfig_copy = tests_names[2]
        target_sshconfig_res = tests_names[3]
        target_sshconfig_bk = tests_names[4]

        copyfile(target_sshconfig_orig, target_sshconfig_copy)

        args = parse_args([target_sshconfig_copy,
                           '--backup_file',
                           target_sshconfig_bk,
                           '--remove',
                           'kdevops,kdevops-dev'])
        run_args(args)
        self.assertTrue(cmp(target_sshconfig_bk,
                            target_sshconfig_orig, shallow = False))
        self.assertTrue(cmp(target_sshconfig_copy,
                            target_sshconfig_res, shallow = False))
    def test_0004_remove_hosts_missing(self):
        this_function_name = inspect.stack()[0][3]
        tests_names = get_test_files(this_function_name)
        target_sshconfig = tests_names[0]
        target_sshconfig_orig = tests_names[1]
        target_sshconfig_copy = tests_names[2]
        target_sshconfig_res = tests_names[3]
        target_sshconfig_bk = tests_names[4]

        copyfile(target_sshconfig_orig, target_sshconfig_copy)

        args = parse_args([target_sshconfig_copy,
                           '--backup_file',
                           target_sshconfig_bk,
                           '--remove',
                           'kdevops,kdevops-dev'])
        run_args(args)
        self.assertTrue(cmp(target_sshconfig_bk,
                            target_sshconfig_orig, shallow = False))
        self.assertTrue(cmp(target_sshconfig_copy,
                            target_sshconfig_res, shallow = False))
    def test_0005_remove_hosts_similar(self):
        this_function_name = inspect.stack()[0][3]
        tests_names = get_test_files(this_function_name)
        target_sshconfig = tests_names[0]
        target_sshconfig_orig = tests_names[1]
        target_sshconfig_copy = tests_names[2]
        target_sshconfig_res = tests_names[3]
        target_sshconfig_bk = tests_names[4]

        copyfile(target_sshconfig_orig, target_sshconfig_copy)

        args = parse_args([target_sshconfig_copy,
                           '--backup_file',
                           target_sshconfig_bk,
                           '--remove',
                           'kdevops,kdevops-dev'])
        run_args(args)
        self.assertTrue(cmp(target_sshconfig_bk,
                            target_sshconfig_orig, shallow = False))
        self.assertTrue(cmp(target_sshconfig_copy,
                            target_sshconfig_res, shallow = False))


if __name__ == '__main__':
    unittest.main(verbosity=2)
