#!/usr/bin/python3
# SPDX-License-Identifier: copyleft-next-0.3.1

# Lists the expunge files which are not yet committed.
#
# Given a directory path it finds all files which are in the expunge directory
# provided for the target filesystem but which are not part of your current git
# tree. This can be used to detect if new failures have been found for a section
# which we had not yet found failures for.

import argparse
import os
import sys
import subprocess
from lib import git

def main():
    parser = argparse.ArgumentParser(description='Get list of expunge files not yet committed in git')
    parser.add_argument('filesystem', metavar='<filesystem name>', type=str,
                        help='filesystem which was tested')
    parser.add_argument('expunge_dir', metavar='<directory with expunge files>', type=str,
                        help='directory with expunge files')
    args = parser.parse_args()

    fs_expunge_dir = args.expunge_dir
    all_files = os.listdir(fs_expunge_dir)

    for root, dirs, all_files in os.walk(fs_expunge_dir):
        for fname in all_files:
            f = os.path.join(root, fname)
            if os.path.isdir(f):
                continue
            if not os.path.isfile(f):
                continue
            if args.filesystem not in (f):
                continue
            pwd = os.getcwd()
            if git.is_new_file(f):
                short_file = f
                if "../" in f:
                    short_file = f.split("../")[1]
                sys.stdout.write("%s\n" % (short_file))

if __name__ == '__main__':
    main()
