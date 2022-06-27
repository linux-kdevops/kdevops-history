#!/usr/bin/python3
# SPDX-License-Identifier: copyleft-next-0.3.1

import unittest
import re
from filecmp import cmp
import inspect
from os import listdir, remove, path
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
                            target_sshconfig_orig, shallow=False))
        self.assertTrue(cmp(target_sshconfig_copy,
                            target_sshconfig_res, shallow=False))

    def test_0002_remove_hosts_middle(self):
        this_function_name = inspect.stack()[0][3]
        tests_names = get_test_files(this_function_name)
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
                            target_sshconfig_orig, shallow=False))
        self.assertTrue(cmp(target_sshconfig_copy,
                            target_sshconfig_res, shallow=False))

    def test_0003_remove_hosts_bottom(self):
        this_function_name = inspect.stack()[0][3]
        tests_names = get_test_files(this_function_name)
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
                            target_sshconfig_orig, shallow=False))
        self.assertTrue(cmp(target_sshconfig_copy,
                            target_sshconfig_res, shallow=False))

    def test_0004_remove_hosts_missing(self):
        this_function_name = inspect.stack()[0][3]
        tests_names = get_test_files(this_function_name)
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
                            target_sshconfig_orig, shallow=False))
        self.assertTrue(cmp(target_sshconfig_copy,
                            target_sshconfig_res, shallow=False))

    def test_0005_remove_hosts_similar(self):
        this_function_name = inspect.stack()[0][3]
        tests_names = get_test_files(this_function_name)
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
                            target_sshconfig_orig, shallow=False))
        self.assertTrue(cmp(target_sshconfig_copy,
                            target_sshconfig_res, shallow=False))

    def test_0006_add_hosts_manual(self):
        this_function_name = inspect.stack()[0][3]
        tests_names = get_test_files(this_function_name)
        target_sshconfig_orig = tests_names[1]
        target_sshconfig_copy = tests_names[2]
        target_sshconfig_res = tests_names[3]
        target_sshconfig_bk = tests_names[4]

        copyfile(target_sshconfig_orig, target_sshconfig_copy)

        args = parse_args(['--addhost',
                           'kdevops,kdevops-dev',
                           '--backup_file',
                           target_sshconfig_bk,
                           '--username',
                           'alpha',
                           '--hostname',
                           '51.179.89.243,52.195.142.19',
                           '--port',
                           '25',
                           '--identity',
                           '~alpha/.ssh/go',
                           '--addstrict',
                           target_sshconfig_copy])
        run_args(args)
        self.assertTrue(cmp(target_sshconfig_bk,
                            target_sshconfig_orig, shallow=False))
        self.assertTrue(cmp(target_sshconfig_copy,
                            target_sshconfig_res, shallow=False))

    def test_0007_add_remove_hosts_two_separate_ops_top(self):
        this_function_name = inspect.stack()[0][3]
        tests_names = get_test_files(this_function_name)
        target_sshconfig = tests_names[0]
        target_sshconfig_orig = tests_names[1]
        target_sshconfig_copy = tests_names[2]

        target_sshconfig_res_remove = target_sshconfig + '.remove.res'
        target_sshconfig_res_add = target_sshconfig + '.add.res'

        target_sshconfig_bk_remove = target_sshconfig + '.remove.bk'
        target_sshconfig_bk_add = target_sshconfig + '.add.bk'

        copyfile(target_sshconfig_orig, target_sshconfig_copy)

        args = parse_args(['--remove',
                           'kdevops,kdevops-dev',
                           '--backup_file',
                           target_sshconfig_bk_remove,
                           '--username',
                           'alpha',
                           '--hostname',
                           '51.179.89.243,52.195.142.19',
                           '--port',
                           '25',
                           '--identity',
                           '~alpha/.ssh/go',
                           '--addstrict',
                           target_sshconfig_copy])
        run_args(args)
        self.assertTrue(cmp(target_sshconfig_bk_remove,
                            target_sshconfig_orig, shallow=False))
        self.assertTrue(cmp(target_sshconfig_copy,
                            target_sshconfig_res_remove, shallow=False))

        args = parse_args(['--addhost',
                           'kdevops,kdevops-dev',
                           '--backup_file',
                           target_sshconfig_bk_add,
                           '--username',
                           'alpha',
                           '--hostname',
                           '51.179.89.243,52.195.142.19',
                           '--port',
                           '25',
                           '--identity',
                           '~alpha/.ssh/go',
                           '--addstrict',
                           target_sshconfig_copy])
        run_args(args)
        self.assertTrue(cmp(target_sshconfig_bk_add,
                            target_sshconfig_res_remove, shallow=False))
        self.assertTrue(cmp(target_sshconfig_copy,
                            target_sshconfig_res_add, shallow=False))

    def test_0008_add_remove_hosts_one_shot_top(self):
        this_function_name = inspect.stack()[0][3]
        tests_names = get_test_files(this_function_name)
        target_sshconfig_orig = tests_names[1]
        target_sshconfig_copy = tests_names[2]
        target_sshconfig_res = tests_names[3]
        target_sshconfig_bk = tests_names[4]

        copyfile(target_sshconfig_orig, target_sshconfig_copy)

        args = parse_args(['--remove',
                           'kdevops,kdevops-dev',
                           '--addhost',
                           'kdevops,kdevops-dev',
                           '--backup_file',
                           target_sshconfig_bk,
                           '--username',
                           'alpha',
                           '--hostname',
                           '51.179.89.243,52.195.142.19',
                           '--port',
                           '25',
                           '--identity',
                           '~alpha/.ssh/go',
                           '--addstrict',
                           target_sshconfig_copy])
        run_args(args)
        self.assertTrue(cmp(target_sshconfig_bk,
                            target_sshconfig_orig, shallow=False))
        self.assertTrue(cmp(target_sshconfig_copy,
                            target_sshconfig_res, shallow=False))

    def test_0009_add_hosts_vagrant_emulate_top(self):
        this_function_name = inspect.stack()[0][3]
        tests_names = get_test_files(this_function_name)
        target_sshconfig = tests_names[0]
        target_sshconfig_orig = tests_names[1]
        target_sshconfig_copy = tests_names[2]
        target_sshconfig_res = tests_names[3]
        target_sshconfig_bk = tests_names[4]

        target_sshconfig_vagrant_input = target_sshconfig + '.emulate_vagrant'

        copyfile(target_sshconfig_orig, target_sshconfig_copy)

        args = parse_args([target_sshconfig_copy,
                           '--backup_file',
                           target_sshconfig_bk,
                           '--remove',
                           'kdevops,kdevops-dev',
                           '--addvagranthosts',
                           '--emulatevagrantinput',
                           target_sshconfig_vagrant_input])
        run_args(args)
        self.assertTrue(cmp(target_sshconfig_bk,
                            target_sshconfig_orig, shallow=False))
        self.assertTrue(cmp(target_sshconfig_copy,
                            target_sshconfig_res, shallow=False))

    def test_0010_add_hosts_kexalgorithms_vagrant_emulate_top(self):
        this_function_name = inspect.stack()[0][3]
        tests_names = get_test_files(this_function_name)
        target_sshconfig = tests_names[0]
        target_sshconfig_orig = tests_names[1]
        target_sshconfig_copy = tests_names[2]
        target_sshconfig_res = tests_names[3]
        target_sshconfig_bk = tests_names[4]

        target_sshconfig_vagrant_input = target_sshconfig + '.emulate_vagrant'

        copyfile(target_sshconfig_orig, target_sshconfig_copy)

        args = parse_args([target_sshconfig_copy,
                           '--backup_file',
                           target_sshconfig_bk,
                           '--remove',
                           'kdevops,kdevops-dev',
                           '--addvagranthosts',
                           '--kexalgorithms',
                           'diffie-hellman-group-exchange-sha1,' +
                           'diffie-hellman-group14-sha1,' +
                           'diffie-hellman-group1-sha1',
                           '--emulatevagrantinput',
                           target_sshconfig_vagrant_input])
        run_args(args)
        self.assertTrue(cmp(target_sshconfig_bk,
                            target_sshconfig_orig, shallow=False))
        self.assertTrue(cmp(target_sshconfig_copy,
                            target_sshconfig_res, shallow=False))

    def test_0011_add_remove_hosts_two_separate_ops_kexalgorithms_top(self):
        this_function_name = inspect.stack()[0][3]
        tests_names = get_test_files(this_function_name)
        target_sshconfig = tests_names[0]
        target_sshconfig_orig = tests_names[1]
        target_sshconfig_copy = tests_names[2]

        target_sshconfig_res_remove = target_sshconfig + '.remove.res'
        target_sshconfig_res_add = target_sshconfig + '.add.res'

        target_sshconfig_bk_remove = target_sshconfig + '.remove.bk'
        target_sshconfig_bk_add = target_sshconfig + '.add.bk'

        copyfile(target_sshconfig_orig, target_sshconfig_copy)

        args = parse_args(['--remove',
                           'kdevops,kdevops-dev',
                           '--backup_file',
                           target_sshconfig_bk_remove,
                           '--username',
                           'alpha',
                           '--hostname',
                           '51.179.89.243,52.195.142.19',
                           '--port',
                           '25',
                           '--identity',
                           '~alpha/.ssh/go',
                           '--kexalgorithms',
                           'diffie-hellman-group-exchange-sha1,' +
                           'diffie-hellman-group14-sha1,' +
                           'diffie-hellman-group1-sha1',
                           '--addstrict',
                           target_sshconfig_copy])
        run_args(args)
        self.assertTrue(cmp(target_sshconfig_bk_remove,
                            target_sshconfig_orig, shallow=False))
        self.assertTrue(cmp(target_sshconfig_copy,
                            target_sshconfig_res_remove, shallow=False))

        args = parse_args(['--addhost',
                           'kdevops,kdevops-dev',
                           '--backup_file',
                           target_sshconfig_bk_add,
                           '--username',
                           'alpha',
                           '--hostname',
                           '51.179.89.243,52.195.142.19',
                           '--port',
                           '25',
                           '--identity',
                           '~alpha/.ssh/go',
                           '--kexalgorithms',
                           'diffie-hellman-group-exchange-sha1,' +
                           'diffie-hellman-group14-sha1,' +
                           'diffie-hellman-group1-sha1',
                           '--addstrict',
                           target_sshconfig_copy])
        run_args(args)
        self.assertTrue(cmp(target_sshconfig_bk_add,
                            target_sshconfig_res_remove, shallow=False))
        self.assertTrue(cmp(target_sshconfig_copy,
                            target_sshconfig_res_add, shallow=False))

    def test_0012_add_remove_hosts_empty_file(self):
        this_function_name = inspect.stack()[0][3]
        tests_names = get_test_files(this_function_name)
        target_sshconfig_orig = tests_names[1]
        target_sshconfig_copy = tests_names[2]
        target_sshconfig_res = tests_names[3]
        target_sshconfig_bk = tests_names[4]

        args = parse_args(['--remove',
                           'kdevops,kdevops-dev',
                           '--addhost',
                           'kdevops,kdevops-dev',
                           '--backup_file',
                           target_sshconfig_bk,
                           '--username',
                           'alpha',
                           '--hostname',
                           '51.179.89.243,52.195.142.19',
                           '--port',
                           '25',
                           '--identity',
                           '~alpha/.ssh/go',
                           '--addstrict',
                           target_sshconfig_copy])
        self.assertTrue(not path.exists(target_sshconfig_orig))
        self.assertTrue(not path.exists(target_sshconfig_copy))
        run_args(args)
        self.assertTrue(not path.exists(target_sshconfig_orig))
        self.assertTrue(not path.exists(target_sshconfig_bk))
        self.assertTrue(path.exists(target_sshconfig_copy))
        self.assertTrue(cmp(target_sshconfig_copy,
                            target_sshconfig_res, shallow=False))

    def tearDown(self):
        files = listdir("tests")
        for testfile in files:
            if testfile.endswith(".copy") or testfile.endswith(".bk"):
                remove(path.join("tests", testfile))


if __name__ == '__main__':
    unittest.main(verbosity=2)
